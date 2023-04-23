defmodule X32Remote do
  use Application
  require Logger

  @default_port 10023

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

      from_app_env = Application.get_env(:x32_remote, :mixer_ip) ->
        from_app_env |> to_ip_tuple()

      from_sys_env = System.get_env("X32R_IP") ->
        from_sys_env |> to_ip_tuple()

      true ->
        raise "x32_remote: Must specify `:ip` in X32Remote.start/2 args, `:mixer_ip` in app environment, or via `X32R_IP` environment variable"
    end
  end

  defp get_port(args) do
    cond do
      from_args = Keyword.get(args, :port) -> from_args
      from_app_env = Application.get_env(:x32_remote, :mixer_port) -> from_app_env
      from_sys_env = System.get_env("X32R_PORT") -> from_sys_env |> String.to_integer()
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
