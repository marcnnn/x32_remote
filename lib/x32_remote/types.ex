defmodule X32Remote.Types do
  @moduledoc """
  Guards and functions relating to X32 argument and return types.
  """

  @typedoc "Fader volume, as integer (`0` to `1024`) or float (`0.0` to `1.0`)"
  @type volume :: 0..1024 | float
  @typedoc "Mono level, as integer (`0` to `160`) or float (`0.0` to `1.0`)"
  @type mono_level :: 0..160 | float
  @typedoc "Panning (left to right), as integer (`0` to `100`) or float (`0.0` to `1.0`)"
  @type panning :: 0..100 | float

  @doc """
  An X32 slider, represented as either a number between `0` and `max` inclusive, or a floating point between `0.0` and `1.0` inclusive.
  """
  defguard is_slider(v, max)
           when (is_float(v) and v >= 0.0 and v <= 1.0) or
                  (is_integer(v) and v >= 0 and v <= max)

  @doc """
  An X32 fader volume slider.  See `is_slider/2`, with a `max` of `1023`.
  """
  defguard is_volume(v) when is_slider(v, 1023)

  @doc """
  An X32 mono volume slider.  See `is_slider/2`, with a `max` of `160`.
  """
  defguard is_mono_level(v) when is_slider(v, 160)

  @doc """
  An X32 panning slider.  See `is_slider/2` with a `max` of `100`.
  """
  defguard is_panning(v) when is_slider(v, 100)

  @doc """
  Converts an X32 arguments list, containing a single `1` or `0` argument, to
  `true` or `false` respectively.
  """
  @spec to_boolean([0..1]) :: boolean
  def to_boolean([0]), do: false
  def to_boolean([1]), do: true

  @doc """
  Converts an X32 arguments list, containing a single floating point argument,
  to a regular floating point.

  Convenience function that can both validate and convert the result as part of
  a `|>` pipeline.
  """
  @spec to_float([float]) :: float
  def to_float([f]) when is_float(f), do: f
end
