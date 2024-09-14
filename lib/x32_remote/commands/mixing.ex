defmodule X32Remote.Commands.Mixing do
  @moduledoc """
  Commands that query or modify how channels are mixed.

  For all functions, the `channel` argument must be a valid channel name, in
  `"type/##"` format.  See `X32Remote.Types.Channel` for a list of valid channels.
  """

  use X32Remote.Commands

  typespec(:channel)
  @type volume :: X32Remote.Types.volume()
  @type panning :: X32Remote.Types.panning()


  @doc """
    Query the Channel Name

    Returns the String
    """
  defcommand name?(session, channel) do
    ensure_channel(channel)
    Session.call_command(session, "/#{channel}/config/name")
    |> to_string()
  end

  @doc """
    Set the Channel Name
    """
  defcommand name(session, channel, name) do
    ensure_channel(channel)
    Session.cast_command(session, "/#{channel}/config/name", [name])
  end



  @doc """
  Query if a channel is muted.

  This corresponds to the red "MUTE" button on the console, which hard-mutes
  the channel, regardless of fader setting.  It does *not* detect if the fader
  volume is non-zero; see `get_fader/2` for that.

  Returns `true` if muted, `false` otherwise.

  ## Example

      iex> X32Remote.Commands.Mixing.muted?(session, "ch/05")
      false
      iex> X32Remote.Commands.Mixing.mute(session, "ch/05")
      :ok
      iex> X32Remote.Commands.Mixing.muted?(session, "ch/05")
      true
  """
  @spec muted?(session, channel) :: boolean
  defcommand muted?(session, channel) do
    ensure_channel(channel)

    Session.call_command(session, "/#{channel}/mix/on", [])
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

      iex> X32Remote.Commands.Mixing.mute(session, "ch/06")
      :ok
      iex> X32Remote.Commands.Mixing.muted?(session, "ch/06")
      true
  """
  @spec mute(session, channel) :: :ok
  defcommand mute(session, channel) do
    ensure_channel(channel)
    Session.cast_command(session, "/#{channel}/mix/on", [0])
  end

  @doc """
  Unmutes a channel.

  This disables the red "MUTE" button on the console, which hard-mutes the
  channel, regardless of fader setting.  It does not alter the fader level; see
  `set_fader/3` for that.

  Returns `:ok` immediately.  Use `muted?/2` if you need to check if the change occurred.

  ## Example

      iex> X32Remote.Commands.Mixing.unmute(session, "ch/07")
      :ok
      iex> X32Remote.Commands.Mixing.muted?(session, "ch/07")
      false
  """
  @spec unmute(session, channel) :: :ok
  defcommand unmute(session, channel) do
    ensure_channel(channel)
    Session.cast_command(session, "/#{channel}/mix/on", [1])
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

      iex> X32Remote.Commands.Mixing.get_fader(session, "ch/17")
      0.7497556209564209
  """
  @spec get_fader(session, channel) :: float
  defcommand get_fader(session, channel) do
    ensure_channel(channel)
    Session.call_command(session, "/#{channel}/mix/fader", []) |> to_float()
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

      iex> X32Remote.Commands.Mixing.set_fader(session, "ch/18", 0.5)
      :ok
      iex> X32Remote.Commands.Mixing.get_fader(session, "ch/18")
      0.4995112419128418
  """
  @spec set_fader(session, channel, volume) :: :ok
  defcommand set_fader(session, channel, volume) when is_volume(volume) do
    ensure_channel(channel)
    Session.cast_command(session, "/#{channel}/mix/fader", [volume])
  end

  @doc """
  Gets the pan (left/right) setting for a channel.

  On the mixer, the pan setting is stored as an integer between `0` (full left)
  and `100` (full right), with `50` as the balanced midpoint.  This function
  returns a normalised approximation of that, which does introduce some
  floating point precision issues.

  Returns a value between `0.0` (full left) and `1.0` (full right).

  ## Example

      iex> X32Remote.Commands.Mixing.get_panning(session, "ch/19")
      0.5
  """
  @spec get_panning(session, channel) :: float
  defcommand get_panning(session, channel) do
    ensure_channel(channel)
    Session.call_command(session, "/#{channel}/mix/pan", []) |> to_float()
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

      iex> X32Remote.Commands.Mixing.set_panning(session, "ch/20", 20)  # or 0.2
      :ok
      iex> X32Remote.Commands.Mixing.get_panning(session, "ch/20")
      0.20000000298023224
  """
  @spec set_panning(session, channel, panning) :: :ok
  defcommand set_panning(session, channel, panning) when is_panning(panning) do
    ensure_channel(channel)
    Session.cast_command(session, "/#{channel}/mix/pan", [panning])
  end
end
