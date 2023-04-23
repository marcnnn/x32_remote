defmodule X32Remote.Supervisor do
  @moduledoc """
  A supervisor that starts a named `ExOSC.Client`, and an `X32Remote.Session` subscribed to it.

  Normally, this is used by `X32Remote` to create the session that will be used
  by `X32Remote.Mixer`.  However, you can also use this in your own code,
  either to start that instance manually, or to conveniently start a supervised
  client + session pair.
  """

  @default_supervisor_name X32Remote.Mixer.Supervisor
  @default_client_name X32Remote.Mixer.Client
  @default_session_name X32Remote.Mixer.Session

  @typedoc "Options used by `start_link/1`"
  @type options :: [option]

  @typedoc "Option values used by `start_link/1`"
  @type option ::
          {:ip, :inet.ip_address()}
          | {:port, :inet.port_number()}
          | {:client_name, GenServer.name()}
          | {:session_name, GenServer.name()}
          | Supervisor.option()
          | Supervisor.init_option()

  @doc """
  Returns a specification to start this supervisor under another supervisor.

  See the "Child specification" section in the `Supervisor` module for more detailed information.
  """
  @spec child_spec(options) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @doc """
  Starts a supervisor that runs a named `ExOSC.Client` and a
  `X32Remote.Session` subscribed to it.

  ## Options

    * `:ip` (required) — target IP in tuple form
    * `:port` (required) — target UDP port
    * `:name` — registered name of the supervisor (default: `#{@default_supervisor_name}`)
    * `:client_name` — registered name of the `ExOSC.Client` process (default: `#{@default_client_name}`)
    * `:session_name` — registered name of the `X32Remote.Session` process (default: `#{@default_session_name}`)

  This function also accepts all the options accepted by `Supervisor.start_link/3`,
  and all of the `name` options accept the same values that function does.

  The `client_name` will be passed to `X32Remote.Session.start_link/1` as the
  `client` option.

  Note that if you use a non-default `session_name`, the `X32Remote.Mixer`
  convenience module will not be using your supervised client and session.

  ## Return values

  Same as `Supervisor.start_link/3`.
  """
  @spec start_link(options) :: Supervisor.on_start()
  def start_link(opts) do
    {ip, opts} = Keyword.pop!(opts, :ip)
    {port, opts} = Keyword.pop!(opts, :port)
    {client_name, opts} = Keyword.pop(opts, :client_name, @default_client_name)
    {session_name, opts} = Keyword.pop(opts, :session_name, @default_session_name)

    opts = Keyword.put_new(opts, :name, @default_supervisor_name)
    opts = Keyword.put_new(opts, :strategy, :one_for_one)

    children = [
      {ExOSC.Client, ip: ip, port: port, name: client_name},
      {X32Remote.Session, client: client_name, name: session_name}
    ]

    Supervisor.start_link(children, opts)
  end
end
