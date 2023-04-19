defmodule X32Remote.Commands.Mix do
  alias X32Remote.Session

  import X32Remote.Types
  import X32Remote.Types.Channels

  def muted?(pid, channel) do
    ensure_channel(channel)

    Session.call_command(pid, "/#{channel}/mix/on", [])
    |> to_boolean()
    |> Kernel.not()
  end

  def mute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [0])
  end

  def unmute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [1])
  end

  def get_fader(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/fader", []) |> to_float()
  end

  def set_fader(pid, channel, volume) when is_volume(volume) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/fader", [volume])
  end

  def get_panning(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/pan", []) |> to_float()
  end

  def set_panning(pid, channel, value) when is_percent(value) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/pan", [value])
  end

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
