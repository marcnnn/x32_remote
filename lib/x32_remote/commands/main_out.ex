defmodule X32Remote.Commands.MainOut do
  @moduledoc """
  Commands that query or modify how channels are routed to the main output.

  For all functions, the `channel` argument must be a valid channel name, in
  `"type/##"` format.  See `X32Remote.Types.Channels` for a list of valid channels.

  #{X32Remote.Commands.shared_moduledoc()}
  """

  alias X32Remote.Session

  import X32Remote.Types
  import X32Remote.Types.Channels

  @doc """
  Query if a channel is sending audio to the stereo ("LR") main output.

  Returns `true` if sending, `false` otherwise.

  ## Example

      iex> X32Remote.Commands.MainOut.main_stereo_out?(session, "bus/03")
      false
      iex> X32Remote.Commands.MainOut.enable_main_stereo_out(session, "bus/03")
      :ok
      iex> X32Remote.Commands.MainOut.main_stereo_out?(session, "bus/03")
      true
  """
  def main_stereo_out?(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/st", []) |> to_boolean()
  end

  @doc """
  Enables sending a channel's audio to the stereo ("LR") main output.

  Returns `:ok` immediately.  Use `main_stereo_out?/2` if you need to check if
  the change occurred.

  ## Example

      iex> X32Remote.Commands.MainOut.enable_main_stereo_out(session, "bus/05")
      :ok
      iex> X32Remote.Commands.MainOut.main_stereo_out?(session, "bus/05")
      true
  """
  def enable_main_stereo_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/st", [1])
  end

  @doc """
  Disables sending a channel's audio to the stereo ("LR") main output.

  Returns `:ok` immediately.  Use `main_stereo_out?/2` if you need to check if
  the change occurred.

  ## Example

      iex> X32Remote.Commands.MainOut.disable_main_stereo_out(session, "bus/06")
      :ok
      iex> X32Remote.Commands.MainOut.main_stereo_out?(session, "bus/06")
      false
  """
  def disable_main_stereo_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/st", [0])
  end

  @doc """
  Query if a channel is sending audio to the mono ("MONO/C") main output.

  Returns `true` if sending, `false` otherwise.

  ## Example

      iex> X32Remote.Commands.MainOut.main_mono_out?(session, "ch/03")
      false
      iex> X32Remote.Commands.MainOut.enable_main_mono_out(session, "ch/03")
      :ok
      iex> X32Remote.Commands.MainOut.main_mono_out?(session, "ch/03")
      true
  """
  def main_mono_out?(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/mono", []) |> to_boolean()
  end

  @doc """
  Enables sending a channel's audio to the mono ("MONO/C") main output.

  Returns `:ok` immediately.  Use `main_mono_out?/2` if you need to check if
  the change occurred.

  ## Example

      iex> X32Remote.Commands.MainOut.enable_main_mono_out(session, "ch/06")
      :ok
      iex> X32Remote.Commands.MainOut.main_mono_out?(session, "ch/06")
      true
  """
  def enable_main_mono_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mono", [1])
  end

  @doc """
  Disables sending a channel's audio to the mono ("MONO/C") main output.

  Returns `:ok` immediately.  Use `main_mono_out?/2` if you need to check if
  the change occurred.

  ## Example

      iex> X32Remote.Commands.MainOut.disable_main_mono_out(session, "ch/09")
      :ok
      iex> X32Remote.Commands.MainOut.main_mono_out?(session, "ch/09")
      false
  """
  def disable_main_mono_out(pid, channel) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mono", [0])
  end

  @doc """
  Gets the main mono ("MONO/C") output level setting for a channel.

  On X32 consoles, this setting is stored as an integer between `0` (silent)
  and `160` (maximum).  This function just returns a normalised approximation
  of that.  To get the internal setting, multiply the result from this function
  by `160` and then use `Kernel.round/1`.

  Returns a value between `0.0` (no output) and `1.0` (maximum output).

  ## Example

      iex> X32Remote.Commands.MainOut.get_main_mono_level(session, "ch/17")
      0.5625
  """
  def get_main_mono_level(pid, channel) do
    ensure_channel(channel)
    Session.call_command(pid, "/#{channel}/mix/mlevel", []) |> to_float()
  end

  @doc """
  Sets the main mono ("MONO/C") output level setting for a channel.

  On X32 consoles, this setting is stored as an integer between `0` (silent)
  and `160` (maximum).  You can specify `level` as either an integer in this
  range, or as a floating point between `0.0` and `1.0`.

  Returns `:ok` immediately.  Use `get_main_mono_level/2` if you need to check if the
  change occurred.  (Due to rounding, you should not expect that this will match
  the value you gave to this function.)

  ## Example

      iex> X32Remote.Commands.MainOut.set_main_mono_level(session, "ch/18", 30)
      :ok
      iex> X32Remote.Commands.MainOut.get_main_mono_level(session, "ch/18")
      0.1875
  """
  def set_main_mono_level(pid, channel, level) when is_mono_level(level) do
    ensure_channel(channel)
    Session.cast_command(pid, "/#{channel}/mix/mlevel", [level])
  end
end
