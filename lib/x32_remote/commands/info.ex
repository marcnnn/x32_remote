defmodule X32Remote.Commands.Info do
  alias X32Remote.Session

  def info(pid), do: Session.call_command(pid, "/info", [])
  def xinfo(pid), do: Session.call_command(pid, "/xinfo", [])
  def status(pid), do: Session.call_command(pid, "/status", [])
end
