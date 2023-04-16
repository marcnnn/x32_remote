defmodule X32Remote.Supervisor do
  def start_link(ip, port) when is_tuple(ip) and is_integer(port) do
    children = [
      {ExOSC.Client, ip: ip, port: port, name: __MODULE__.Client},
      {X32Remote.Session, client: __MODULE__.Client, name: __MODULE__.Session}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
