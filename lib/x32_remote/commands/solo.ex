defmodule X32Remote.Commands.Solo do
  alias X32Remote.Session

  import X32Remote.Types
  import X32Remote.Types.Channels

  @solo_ids [
              ch: 1..32,
              auxin: 33..40,
              fxrtn: 41..48,
              bus: 49..64,
              mtx: 65..70
            ]
            |> Enum.flat_map(fn {prefix, range} ->
              range
              |> Enum.with_index()
              |> Enum.map(fn {id, index} ->
                suffix = to_twodigit(index + 1)
                id = to_twodigit(id)
                {"#{prefix}/#{suffix}", id}
              end)
            end)
            |> Map.new()

  def solo?(pid, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.call_command(pid, "/-stat/solosw/#{id}", []) |> to_boolean()
  end

  def enable_solo(pid, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.cast_command(pid, "/-stat/solosw/#{id}", [1])
  end

  def disable_solo(pid, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.cast_command(pid, "/-stat/solosw/#{id}", [0])
  end

  def any_solo?(pid) do
    Session.call_command(pid, "/-stat/solo", []) |> to_boolean()
  end

  def clear_solo(pid) do
    Session.cast_command(pid, "/-action/clearsolo", [1])
  end
end
