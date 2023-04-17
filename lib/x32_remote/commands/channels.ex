defmodule X32Remote.Commands.Channels do
  alias X32Remote.Session

  require X32Remote.Guards
  import X32Remote.Guards
  import X32Remote.Guards.Channels, only: [ensure_channel: 1]

  def muted?(pid, channel) do
    ensure_channel(channel)

    case Session.call_command(pid, "/#{channel}/mix/on", []) do
      [1] -> false
      [0] -> true
    end
  end

  def mute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [0])
  end

  def unmute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [1])
  end

  def fader_get(pid, channel) do
    ensure_channel(channel)

    Session.call_command(pid, "/#{channel}/mix/fader", [])
    |> then(fn [v] when is_float(v) -> v end)
  end

  def fader_set(pid, channel, volume) when is_volume(volume) do
    ensure_channel(channel)

    Session.cast_command(pid, "/#{channel}/mix/fader", [volume])
  end
end
