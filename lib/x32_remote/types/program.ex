defmodule X32Remote.Types.Program do
  @moduledoc """
  Guards and functions for cues, scenes, snippets, and channel presets.

  Channel presets are numbered from `001` to `100`.  All of these (other than
  `100`) **must** be zero-padded.  E.g. `042` is a valid channel preset, `42` is
  not.

  The other types are numbered from `000` to `099`.  These must all be
  zero-padded as well, even though the first digit will always be a zero.
  """

  @typedoc "A channel preset identifier, numbered from `1` to `100`"
  @type preset :: 1..100
  @typedoc "A cue identifier, numbered from `0` to `99`"
  @type cue :: 0..99
  @typedoc "A scene identifier, numbered from `0` to `99`"
  @type scene :: 0..99
  @typedoc "A snippet identifier, numbered from `0` to `99`"
  @type snippet :: 0..99
  @typedoc "A one- to three-digit integer, as a three-character zero-padded string."
  @type threedigit :: <<_::24>>

  @doc """
  Returns `true` if `term` is a channel preset identifier; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_preset(term) :: boolean
  defguard is_preset(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a cue identifier; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_cue(term) :: boolean
  defguard is_cue(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a scene identifier; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_scene(term) :: boolean
  defguard is_scene(term) when term in 0..99

  @doc """
  Returns `true` if `term` is a snippet identifier; otherwise returns `false`.

  Allowed in guard tests.  Inlined by the compiler.
  """
  @doc guard: true
  @spec is_snippet(term) :: boolean
  defguard is_snippet(term) when term in 0..99
end
