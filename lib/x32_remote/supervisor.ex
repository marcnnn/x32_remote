defmodule X32Remote.Supervisor do
  @default_supervisor_name X32Remote.Mixer.Supervisor
  @default_client_name X32Remote.Mixer.Client
  @default_session_name X32Remote.Mixer.Session

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

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
