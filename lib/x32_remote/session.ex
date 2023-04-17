defmodule X32Remote.Session do
  use GenStage
  require Logger

  alias OSC.Message
  import X32Remote.Guards

  defmodule State do
    @enforce_keys [:client]
    defstruct(
      client: nil,
      replies: %{}
    )
  end

  def start_link(opts) do
    {client, opts} = Keyword.pop!(opts, :client)

    GenStage.start_link(__MODULE__, client, opts)
  end

  def call_message(pid, %Message{} = msg) when is_name(pid) do
    GenStage.call(pid, {:send_wait, msg})
  end

  def cast_message(pid, %Message{} = msg) when is_name(pid) do
    GenStage.cast(pid, {:send, msg})
  end

  def call_command(pid, cmd, args \\ []) when is_name(pid) and is_binary(cmd) and is_list(args) do
    msg = Message.construct(cmd, args)
    call_message(pid, msg)
  end

  def cast_command(pid, cmd, args \\ []) when is_name(pid) and is_binary(cmd) and is_list(args) do
    msg = Message.construct(cmd, args)
    cast_message(pid, msg)
  end

  @impl true
  def init(client) when is_name(client) do
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
    {reply_to, replies} = Map.pop(state.replies, msg.path |> reply_lookup_path(), [])
    Enum.each(reply_to, &GenStage.reply(&1, msg.args))
    %State{state | replies: replies}
  end

  # For some reason, requests with path "/node" are answered by replies with path "node".
  # This reverses that.
  #
  # Note that this is currently only intended for ease of use while exploring the API.
  # There are zero API functions that rely on "/node" commands.
  #
  # If you're using this in your own code, keep in mind that if you issue a lot
  # of different "/node" requests in rapid succession, it's very likely that
  # you'll start getting responses that don't match your requests.
  #
  # To prevent this, it should be possible to look at the contents of the
  # reply, and ensure that the first word at least contains the query string.
  # But since (again) this is just for exploratory use, this will do for now.
  defp reply_lookup_path("node"), do: "/node"
  defp reply_lookup_path(path), do: path
end
