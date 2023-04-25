defmodule X32Remote.Types.Program do
  @moduledoc """
  Guards and functions for cues, scenes, snippets, and channel presets.

  Cues, scenes, and snippet slots are integeres numbered from `0` to `99`.

  Channel preset slots are integers numbered from `1` to `100`.

  When used in string format as part of a message path, such as when querying
  specific data about a given slot, these numbers must be formatted as
  three-digit, zero-padded strings.  E.g. `"042"` is a valid scene slot, `"42"` is
  not.

  As such, this module also contains functions to convert between integers and
  three-digit zero-padded strings.
  """

  @typedoc "A channel preset slot, numbered from `1` to `100`."
  @type preset :: 1..100
  @typedoc "A cue slot, numbered from `0` to `99`."
  @type cue :: 0..99
  @typedoc "A scene slot, numbered from `0` to `99`."
  @type scene :: 0..99
  @typedoc "A snippet slot, numbered from `0` to `99`."
  @type snippet :: 0..99

  @typedoc "A slot number for a programmable mixer element."
  @type slot :: preset | cue | scene | snippet
  @typedoc "A slot number, as a three-character zero-padded string."
  @type threedigit :: <<_::24>>

  @doc """
  Returns `true` if `term` is a channel preset slot; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_preset(term) :: boolean
  defguard is_preset(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a cue slot; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_cue(term) :: boolean
  defguard is_cue(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a scene slot; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_scene(term) :: boolean
  defguard is_scene(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a snippet slot; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_snippet(term) :: boolean
  defguard is_snippet(term) when term in 0..99

  @doc """
  Converts a three-digit string into a slot number.

  Faster than `String.to_integer/1` for this specific case.
  """
  @digits ?0..?9
  @spec from_threedigit(threedigit) :: slot
  def from_threedigit(<<hundred, ten, one>> = _s)
      when hundred in ?0..?1 and ten in @digits and one in @digits,
      do: (hundred - ?0) * 100 + (ten - ?0) * 10 + (one - ?0)

  @doc """
  Converts slot number into a three-character zero-padded string.

  Faster than `Integer.to_string/1` + `String.pad_leading/3`.
  """
  @spec to_threedigit(slot) :: threedigit
  def to_threedigit(n) when n in 0..9, do: "00#{n}"
  def to_threedigit(n) when n in 10..99, do: "0#{n}"
  def to_threedigit(n) when n == 100, do: "#{n}"
end
