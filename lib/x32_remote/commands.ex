defmodule X32Remote.Commands do
  @moduledoc false

  @shared_moduledoc """
  All functions in this module take the process ID or name of an
  `X32Remote.Session` process as their first argument.  For more convenient
  versions that omit this first argument, see `X32Remote.Mixer`.
  """

  def insert_shared_moduledoc(nil), do: nil

  # Inserts @shared_moduledoc just before the first section header (if any).
  def insert_shared_moduledoc(doc) when is_binary(doc) do
    case String.split(doc, ~r/^#/m, parts: 2) do
      [header, rest] ->
        "#{header}#{@shared_moduledoc}\n##{rest}"

      all ->
        "#{all}\n\n#{@shared_moduledoc}"
    end
  end

  def call(:subscribe, path, result_fun) do
    {:subscribe, path, result_fun}
  end

  def call(session, path, result_fun) when is_pid(session) or is_atom(session) do
    X32Remote.Session.call_command(session, path, [])
    |> result_fun.()
  end

  defmacro __using__(_opts) do
    quote do
      use X32Remote.Builder.Commands

      alias X32Remote.Session
      alias X32Remote.Commands

      require X32Remote.Types.Specs
      import X32Remote.Types
      import X32Remote.Types.Channel
      import X32Remote.Types.Specs, only: [typespec: 1]

      @moduledoc @moduledoc |> X32Remote.Commands.insert_shared_moduledoc()

      @type session :: X32Remote.Session.session()
    end
  end
end
