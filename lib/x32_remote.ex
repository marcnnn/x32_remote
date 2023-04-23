defmodule X32Remote do
  @default_port 10023

  @moduledoc """
  The X32Remote application.

  By default, on startup, this will run `X32Remote.Supervisor.start_link/1` to
  start an `X32Remote.Session` subscribed to an `ExOSC.Client`.  To disable
  this behaviour, set the `start` configuration property to `false` in
  `config/config.exs`:

      config :x32_remote, start: false

  ## Mixer IP address

  To find the mixer, you will need to specify an IP address.  (You may also
  need to specify a port if your device does not use the default of
  `#{@default_port}`.)

  If you know the IP address of your X32 mixer at compile time, you can set it
  in your `config/config.exs`.  Alternatively, if you need to perform some
  lookup at runtime in order to find your mixer, you can set it in your
  `config/runtime.exs`.  Either way, the syntax is the same.

      # port is optional:
      config :x32_remote, ip: {192, 168, 2, 3}, port: 10023
      # this also works:
      config :x32_remote, ip: "192.168.2.3"

  You can also set the `X32R_IP` environment variable:

      export X32R_IP=192.168.2.3
      # can also optionally specify port:
      export X32R_PORT=10023
      # now run your program as normal

  If you do not specify an IP address, and do not disable the automatic startup
  behaviour, then an error will be raised on application start.
  """

  use Application
  require Logger

  @spec start(Application.start_type(), term) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: term()}
  @impl true
  def start(_type, args) do
    if Application.get_env(:x32_remote, :start, true) do
      ip = get_ip(args)
      port = get_port(args)

      Logger.info("X32Remote starting, using mixer at #{format_ip(ip)}:#{port}.")
      X32Remote.Supervisor.start_link(ip: ip, port: port)
    else
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end

  defp get_ip(args) do
    cond do
      from_args = Keyword.get(args, :ip) ->
        from_args |> to_ip_tuple()

      from_sys_env = System.get_env("X32R_IP") ->
        from_sys_env |> to_ip_tuple()

      from_app_env = Application.get_env(:x32_remote, :ip) ->
        from_app_env |> to_ip_tuple()

      true ->
        raise "x32_remote: Must specify `:ip` in X32Remote.start/2 args, `:ip` in app environment, or via `X32R_IP` environment variable"
    end
  end

  defp get_port(args) do
    cond do
      from_args = Keyword.get(args, :port) -> from_args
      from_sys_env = System.get_env("X32R_PORT") -> from_sys_env |> String.to_integer()
      from_app_env = Application.get_env(:x32_remote, :port) -> from_app_env
      true -> @default_port
    end
  end

  defp to_ip_tuple(ip) when is_tuple(ip), do: ip

  defp to_ip_tuple(ip) when is_binary(ip) do
    {:ok, ip} = ip |> String.to_charlist() |> :inet.parse_address()
    ip
  end

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"

  defp format_ip({_, _, _, _, _, _, _, _} = ip6) do
    ip6
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer(&1, 16))
    |> Enum.join(":")
  end
end
