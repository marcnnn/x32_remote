defmodule X32Remote.Types do
  @moduledoc """
  Guards and functions relating to X32 argument and return types.
  """

  @doc false
  @spec is_slider(term, integer) :: boolean
  defguard is_slider(term, max)
           when (is_float(term) and term >= 0.0 and term <= 1.0) or
                  (is_integer(term) and term >= 0 and term <= max)

  @typedoc "Fader volume, as integer (`0` to `1024`) or float (`0.0` to `1.0`)"
  @type volume :: 0..1024 | float

  @doc """
  Returns `true` if `term` is an X32 fader volume; otherwise returns `false`.

  X32 fader volumes are represented as either an integer between `0` (silent)
  and `1023` (max volume), or a float between `0.0` (silent) and `1.0` (max
  volume).

  Commands that get volume will always return the float value.  Commands that
  set volume can accept either value.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_volume(term) :: boolean
  defguard is_volume(term) when is_slider(term, 1023)

  @typedoc "Mono level, as integer (`0` to `160`) or float (`0.0` to `1.0`)"
  @type mono_level :: 0..160 | float

  @doc """
  Returns `true` if `term` is an X32 mono level; otherwise returns `false`.

  X32 mono levels are represented as either an integer between `0` (silent)
  and `160` (max volume), or a float between `0.0` (silent) and `1.0` (max
  volume).

  Commands that get mono levels will always return the float value.  Commands
  that set mono levels can accept either value.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_mono_level(term) :: boolean
  defguard is_mono_level(term) when is_slider(term, 160)

  @typedoc "Panning (left to right), as integer (`0` to `100`) or float (`0.0` to `1.0`)"
  @type panning :: 0..100 | float

  @doc """
  Returns `true` if `term` is an X32 panning value; otherwise returns `false`.

  X32 panning levels are represented as either an integer between `0` (full left)
  and `100` (full right), or a float between `0.0` (full left) and `1.0` (full right).

  The middle (balanced) value is `50` or `0.5`, respectively.

  Commands that get panning values will always return the float value.
  Commands that set panning values can accept either type.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_panning(term) :: boolean
  defguard is_panning(term) when is_slider(term, 100)

  @doc """
  Takes a list with a single `0`/`1` integer, and returns `false`/`true` respectively.

  This is a convenience function, due to how many X32 commands return this as their arguments.
  """
  @spec to_boolean([0..1]) :: boolean
  def to_boolean([0]), do: false
  def to_boolean([1]), do: true

  @doc """
  Takes a list with a single float, and returns that float.

  This is a convenience function, due to how many X32 commands return this as their arguments.
  """
  @spec to_float([float]) :: float
  def to_float([f]) when is_float(f), do: f
end
