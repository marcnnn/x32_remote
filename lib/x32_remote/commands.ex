defmodule X32Remote.Commands do
  @moduledoc false

  @shared_moduledoc """
  All functions in this module take the process ID or name of an
  `X32Remote.Session` process as their first argument.  For more convenient
  versions that omit this first argument, see `X32Remote.Mixer`.
  """

  def shared_moduledoc, do: @shared_moduledoc

  defmacro __using__(_opts) do
    quote do
      use X32Remote.Builder.Commands

      alias X32Remote.Session

      require X32Remote.Types.Specs
      import X32Remote.Types
      import X32Remote.Types.Channel
      import X32Remote.Types.Specs, only: [typespec: 1]

      if @moduledoc do
        @moduledoc @moduledoc <> "\n\n" <> X32Remote.Commands.shared_moduledoc()
      end

      @type session :: X32Remote.Session.session()
    end
  end
end
