defmodule X32Remote.Types.Channel do
  @moduledoc """
  Guards and functions specifically for channel names, in `type/##` format.

  ## Valid channels

  The following names are considered valid:

  * `ch/01` through `ch/32`
  * `auxin/01` through `auxin/08`
  * `fxrtn/01` through `fxrtn/08`
  * `bus/01` through `bus/16`
  * `mtx/01` through `mtx/06`
  * `main/st` and `main/m`

  All single-digit numbers **must** be zero-padded.  E.g. `ch/05` is a valid
  channel, `ch/5` is not.
  """

  @typedoc "An X32 mixer channel, in `type/##` format"
  @type channel :: binary
  @typedoc "A one- or two-digit integer."
  @type twodigit_integer :: 0..99
  @typedoc "A one- or two-digit integer, as a two-character zero-padded string."
  @type twodigit_binary :: <<_::16>>

  @doc """
  Checks if a string refers to a valid channel name.

  Returns true if valid, false otherwise.
  """
  @spec channel?(binary) :: boolean
  def channel?("ch/" <> id = _ch), do: check_twodigit(id, 1..32)
  def channel?("auxin/" <> id), do: check_twodigit(id, 1..8)
  def channel?("fxrtn/" <> id), do: check_twodigit(id, 1..8)
  def channel?("bus/" <> id), do: check_twodigit(id, 1..16)
  def channel?("mtx/" <> id), do: check_twodigit(id, 1..6)
  def channel?("main/st"), do: true
  def channel?("main/m"), do: true
  def channel?(_ch), do: false

  @doc """
  Converts a two-character string into a one- or two-digit integer.

  Faster than `String.to_integer/1` for this specific case.
  """
  @digits ?0..?9
  @spec from_twodigit(twodigit_binary) :: twodigit_integer
  def from_twodigit(<<t, n>> = _s) when t in @digits and n in @digits,
    do: (t - ?0) * 10 + n - ?0

  @doc """
  Converts a one- or two-digit integer into a two-character zero-padded string.

  Faster than `Integer.to_string/1` + `String.pad_leading/3`.
  """
  @spec to_twodigit(twodigit_integer) :: twodigit_binary
  def to_twodigit(n) when n >= 0 and n <= 9, do: "0#{n}"
  def to_twodigit(n) when n >= 10 and n <= 99, do: "#{n}"

  defp check_twodigit(str, range) do
    try do
      from_twodigit(str) in range
    rescue
      FunctionClauseError -> false
    end
  end

  @doc """
  Runtime assertion to ensure that a channel name is valid.

  Returns `ch` if `channel?/1` returns `true`.  Raises `ArgumentError` otherwise.

  This could technically be a guard, but the guard version was extremely
  verbose on error, and about 2.8x slower besides.
  """
  @spec ensure_channel(binary) :: binary
  def ensure_channel(ch) do
    if channel?(ch) do
      ch
    else
      raise ArgumentError, "Invalid channel specifier: #{inspect(ch)}"
    end
  end
end
