defmodule X32Remote.Commands.Setup do
  alias X32Remote.Session

  def clock_set(pid, %NaiveDateTime{} = ndt) do
    Session.cast_command(pid, "/-action/setclock", [ndt |> Calendar.strftime("%Y%m%d%H%M%S")])
  end
end
