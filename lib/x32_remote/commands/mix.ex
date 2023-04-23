defmodule X32Remote.Commands.Mix do
  @moduledoc """
  Commands that query or modify how channels are mixed.

  For all functions, the `channel` argument must be a valid channel name, in
  `"type/##"` format.  See `X32Remote.Types.Channels` for a list of valid channels.

  #{X32Remote.Commands.shared_moduledoc()}
  """

  alias X32Remote.Session

  import X32Remote.Types
  import X32Remote.Types.Channels

  @doc """
  Query if a channel is muted.

  This corresponds to the red "MUTE" button on the console, which hard-mutes
  the channel, regardless of fader setting.  It does *not* detect if the fader
  volume is non-zero; see `get_fader/2` for that.

  Returns `true` if muted, `false` otherwise.

  ## Example

      iex> X32Remote.Commands.Mix.muted?(session, "ch/05")
      false
      iex> X32Remote.Commands.Mix.mute(session, "ch/05")
      :ok
      iex> X32Remote.Commands.Mix.muted?(session, "ch/05")
      true
  """
  def muted?(pid, channel) do
    ensure_channel(channel)

    Session.call_command(pid, "/#{channel}/mix/on", [])
    |> to_boolean()
    |> Kernel.not()
  end

  @doc """
  Mutes a channel.

  This enables the red "MUTE" button on the console, which hard-mutes the
  channel, regardless of fader setting.  It does not alter the fader level; see
  `set_fader/3` for that.

  Returns `:ok` immediately.  Use `muted?/2` if you need to check if the change occurred.

  ## Example

      iex> X32Remote.Commands.Mix.mute(session, "ch/06")
      :ok
      iex> X32Remote.Commands.Mix.muted?(session, "ch/06")
      true
  """
  def mute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [0])
  end

  @doc """
  Unmutes a channel.

  This disables the red "MUTE" button on the console, which hard-mutes the
  channel, regardless of fader setting.  It does not alter the fader level; see
  `set_fader/3` for that.

  Returns `:ok` immediately.  Use `muted?/2` if you need to check if the change occurred.

  ## Example

      iex> X32Remote.Commands.Mix.unmute(session, "ch/07")
      :ok
      iex> X32Remote.Commands.Mix.muted?(session, "ch/07")
      false
  """
  def unmute(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/on", [1])
  end

  @doc """
  Gets the fader setting for a channel.

  This corresponds to the main fader slider for the channel.

  On X32 consoles, fader settings are stored as an integer between `0` (silent)
  and `1023` (maximum).  This function just returns a normalised approximation
  of that.  To get the internal setting, multiply the result from this function
  by `1023` and then use `Kernel.round/1`.

  Returns a value between `0.0` (silent) and `1.0` (maximum volume).

  ## Example

      iex> X32Remote.Commands.Mix.get_fader(session, "ch/17")
      0.7497556209564209
  """
  def get_fader(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/fader", []) |> to_float()
  end

  @doc """
  Sets the fader setting for a channel.

  This corresponds to the main fader slider for the channel.

  On X32 consoles, fader settings are stored as an integer between `0` (silent)
  and `1023` (maximum).  You can specify `volume` as either an integer in this
  range, or as a floating point between `0.0` and `1.0`.

  Returns `:ok` immediately.  Use `get_fader/2` if you need to check if the
  change occurred.  (Due to rounding, you should not expect that this will match
  the value you gave to this function.)

  ## Example

      iex> X32Remote.Commands.Mix.set_fader(session, "ch/18", 0.5)
      :ok
      iex> X32Remote.Commands.Mix.get_fader(session, "ch/18")
      0.4995112419128418
  """
  def set_fader(pid, channel, volume) when is_volume(volume) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/fader", [volume])
  end

  @doc """
  Gets the pan (left/right) setting for a channel.

  On the mixer, the pan setting is stored as an integer between `0` (full left)
  and `100` (full right), with `50` as the balanced midpoint.  This function
  returns a normalised approximation of that, which does introduce some
  floating point precision issues.

  Returns a value between `0.0` (full left) and `1.0` (full right).

  ## Example

      iex> X32Remote.Commands.Mix.get_panning(session, "ch/19")
      0.5
  """
  def get_panning(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/pan", []) |> to_float()
  end

  @doc """
  Sets the pan (left/right) setting for a channel.

  On the mixer, the pan setting is stored as an integer between `0` (full left)
  and `100` (full right), with `50` as the balanced midpoint.  You can specify
  `value` as either an integer in this range, or as a floating point between
  `0.0` and `1.0`.

  Returns `:ok` immediately.  Use `get_panning/2` if you need to check if the
  change occurred.  (Due to rounding, you should not expect that this will match
  the value you gave to this function.)

  ## Example

      iex> X32Remote.Commands.Mix.set_panning(session, "ch/20", 20)  # or 0.2
      :ok
      iex> X32Remote.Commands.Mix.get_panning(session, "ch/20")
      0.20000000298023224
  """
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
