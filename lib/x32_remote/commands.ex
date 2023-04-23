defmodule X32Remote.Commands do
  @moduledoc false

  @shared_moduledoc """
  All functions in this module take the process ID or name of an
  `X32Remote.Session` process as their first argument.  For more convenient
  versions that omit this first argument, see `X32Remote.Mixer`.
  """

  def shared_moduledoc, do: @shared_moduledoc
end
