defmodule X32Remote.Commands.MainOut do
  @moduledoc """
  Commands that query or modify how channels are mixed.

  For all functions, the `channel` argument must be a valid channel name, in
  `"type/##"` format.  See `X32Remote.Types.Channels` for a list of valid channels.

  #{X32Remote.Commands.shared_moduledoc()}
  """

  alias X32Remote.Session

  import X32Remote.Types
  import X32Remote.Types.Channels

  def main_stereo_out?(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/st", []) |> to_boolean()
  end

  def enable_main_stereo_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/st", [1])
  end

  def disable_main_stereo_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/st", [0])
  end

  def main_mono_out?(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/mono", []) |> to_boolean()
  end

  def enable_main_mono_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mono", [1])
  end

  def disable_main_mono_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mono", [0])
  end

  def get_main_mono_level(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/mlevel", []) |> to_float()
  end

  def set_main_mono_level(pid, channel, level) when is_mono_level(level) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mlevel", [level])
  end
end
