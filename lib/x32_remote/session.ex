defmodule X32Remote.Session do
  @moduledoc """
  A module for running commands on an X32 mixer.

  To use this module, you will need to create an `ExOSC.Client` process (via
  `ExOSC.Client.start_link/1`) that points to the target mixer IP and port.
  Then you can start this module using `start_link/1`, specifying the client
  PID via the (mandatory) `client` argument.  (The `GenStage` subscription will
  be set up automatically.)

  To run commands on the mixer, you can use either `call_command/3` if you
  expect a reply, or `cast_command/3` if you do not.  (See the "How replies
  work" section below.)

  Most programs will not need to directly use this module at all.
  `X32Remote.Mixer` provides a ready-to-use version of the X32 command set,
  suitable for use if your program only needs to talk to a single mixer.  If
  you need to talk to multiple mixers simultaneously, you can still use the
  `X32Remote.Commands.*` modules to use the X32 command set.  Using the call/cast
  functions directly can be useful for commands that this library does not
  (yet) support, however.

  ## How replies work

  Technically, the OSC protocol is stateless and symmetrical — there is no
  built-in concept of "replies".

  To simulate replies, when receiving an OSC message that requests the value of
  a mixer parameter at a given `path`, the X32 devices responds by sending a
  return message using the same `path`, with the response data in the
  arguments.

  For our purposes, this creates a number of issues:

  ### Commands without replies

  Many commands do not produce a reply.  As a general rule, commands that
  **get** mixer parameters will have a reply, while those that **set** mixer
  parameters will not.  (There are exceptions to both of these rules, though.)

  Typically, these "getters" and "setters" both use the same `path`, with their
  behaviour depending on whether the request has arguments or not.  For
  example, getting the fader level of `ch/01` involves two messages (request
  and a reply):

      X32Remote.Session.call_command(session, "/ch/01/mix/fader", [])
      >>> %OSC.Message{path: "/ch/01/mix/fader", args: []}
      <<< %OSC.Message{path: "/ch/01/mix/fader", args: [1.0]}
      [1.0]

  While setting the fader level uses the same path, but only an outbound
  message, with no reply:

      X32Remote.Session.cast_command(session, "/ch/01/mix/fader", [0.5])
      >>> %OSC.Message{path: "/ch/01/mix/fader", args: [0.5]}

  Thus, to set the fader level, you must use the `cast_*` function variants,
  not the `call_*` variants.

  More generally, you need to know what kind of command you're running, and
  whether you can expect it to produce a reply or not.  Attempting to use
  `call_*` functions on a command with no reply will result in a timeout.

  ### Invalid commands

  The X32 does not produce any sort of message if you issue an invalid command.
  Any error or typo in the request path will just result in no reply.

  For example, trying to get the fader of `ch/1` (instead of `ch/01`) results in no reply:

      X32Remote.Session.call_command(session, "/ch/1/mix/fader", [])
      >>> %OSC.Message{path: "/ch/1/mix/fader", args: []}
      [... five seconds pass ...]
      ** (exit) exited in: GenServer.call(...)
        ** (EXIT) time out

  There's no real solution here except to always ensure you're supplying a
  valid command path, which (in many cases) also means ensuring you supply a
  valid, existing channel name.

  ### Race conditions

  Aside from the path, there is no way to identify **exactly** which "get"
  command a reply is in response to.

  Given this limitation, there are at least two cases where we might issue a
  request for a fader parameter, but before we can receive "our" reply, we
  receive a different matching message for that parameter:

  * If multiple processes are using the same `X32Remote.Session` (or the
  underlying `ExOSC.Client`) and they issue the same "get" command at the same
  time.

  * If you issue the `/xremote` command (which reports whenever mixer settings
  change) and the value gets changed as you're requesting it.

  However, this is not usually a problem, since you're receiving current
  information about the resource you requested either way.

  (Be aware that when you issue "set" commands, those changes may not
  immediately show up in "get" commands, even if you are the only client
  talking to the mixer.)
  """
  use GenStage
  require Logger

  alias OSC.Message

  defmodule State do
    @moduledoc false
    @enforce_keys [:client]
    defstruct(
      client: nil,
      replies: %{}
    )
  end

  @typedoc "A reference to a running `X32Remote.Session`"
  @type session :: GenStage.stage()

  @typedoc "Options used by `start_link/1`"
  @type options :: [option]

  @typedoc "Option values used by `start_link/1`"
  @type option :: {:client, GenStage.stage()} | GenServer.option()

  @doc """
  Starts a session that will send and receive messages to/from the given client.

  ## Options

    * `:client` (required) — PID or name of an `ExOSC.Client` process.  (See the "Name registration" section of `GenServer` for acceptable values.)

  This function also accepts all the options accepted by `GenServer.start_link/3`.

  ## Return values

  Same as `GenServer.start_link/3`.
  """
  @spec start_link(options) :: GenServer.on_start()
  def start_link(opts) do
    {client, opts} = Keyword.pop!(opts, :client)

    GenStage.start_link(__MODULE__, client, opts)
  end

  @doc """
  Sends a request message to the mixer, then waits for a reply message and returns it.

  `session` can any of the values detailed in the "Name registration" section
  of the `GenServer` documentation.

  This is a lower-level version of `call_command/3`.  In most cases, you can
  use that instead.

  Returns the received reply, as an `OSC.Message` structure.
  """
  @spec call_message(session, Message.t()) :: Message.args()
  def call_message(session, %Message{} = msg) do
    GenStage.call(session, {:send_wait, msg})
  end

  @doc """
  Sends a request message to the mixer.  Does not wait for a reply.

  `session` can any of the values detailed in the "Name registration" section
  of the `GenServer` documentation.

  `msg` should be a valid `OSC.Message` structure.

  This is a lower-level version of `cast_command/3`.  In most cases, you can
  use that instead.

  Always returns `:ok` immediately, regardless of whether the session exists,
  and/or whether it handled the message successfully.
  """
  @spec cast_message(session, Message.t()) :: :ok
  def cast_message(session, %Message{} = msg) do
    GenStage.cast(session, {:send, msg})
  end

  @doc """
  Constructs and sends a request message to the mixer, then waits for a reply
  message and returns its arguments.

  `session` can any of the values detailed in the "Name registration" section
  of the `GenServer` documentation.

  `path` and `args` will become the path and arguments of the `OSC.Message` request.

  Returns the `args` list from the received reply.
  """
  @spec call_command(session, Message.path(), Message.args()) :: Message.args()
  def call_command(session, path, args \\ []) do
    msg = Message.construct(path, args)
    call_message(session, msg).args
  end

  @doc """
  Constructs and sends a request message to the mixer.  Does not wait for a reply.

  `session` can any of the values detailed in the "Name registration" section
  of the `GenServer` documentation.

  `path` and `args` will become the path and arguments of the `OSC.Message` request.

  Always returns `:ok` immediately, regardless of whether the session exists,
  and/or whether it handled the message successfully.
  """
  @spec cast_command(session, Message.path(), Message.args()) :: :ok
  def cast_command(session, path, args \\ []) do
    msg = Message.construct(path, args)
    cast_message(session, msg)
  end

  @impl true
  def init(client) do
    GenStage.async_subscribe(self(), to: client)
    {:consumer, %State{client: client}}
  end

  @impl true
  def handle_call({:send_wait, msg}, from, state) do
    Logger.debug(">>> #{inspect(msg)}")
    ExOSC.Client.send_message(state.client, msg)
    {:noreply, [], state |> add_pending_reply(msg, from)}
  end

  @impl true
  def handle_cast({:send, msg}, state) do
    Logger.debug(">>> #{inspect(msg)}")
    ExOSC.Client.send_message(state.client, msg)
    {:noreply, [], state}
  end

  defp add_pending_reply(%State{replies: replies} = state, %Message{path: path}, from) do
    replies = Map.update(replies, path, [from], fn existing -> [from | existing] end)
    %State{state | replies: replies}
  end

  @impl true
  def handle_events(events, {_, _}, state) do
    state = Enum.reduce(events, state, &handle_one_event/2)
    {:noreply, [], state}
  end

  defp handle_one_event(%Message{} = msg, state) do
    Logger.debug("<<< #{inspect(msg)}")
    {reply_to, replies} = Map.pop(state.replies, msg.path, [])
    Enum.each(reply_to, &GenStage.reply(&1, msg))
    %State{state | replies: replies}
  end
end
