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
      require X32Remote.Commands
      import X32Remote.Commands, only: [defcommand: 2]

      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      @before_compile X32Remote.Commands
      @moduledoc @moduledoc <> "\n\n" <> X32Remote.Commands.shared_moduledoc()
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __commands__, do: @commands
    end
  end

  defmacro defcommand(defn, body) do
    {fname, args} = X32Remote.Commands.extract_signature(defn)

    quote do
      @commands {unquote(fname), unquote(args), @doc |> X32Remote.Commands.doc_summary()}
      def unquote(defn), unquote(body)
    end
  end

  def extract_signature({:when, _, [defn | _]}) do
    extract_signature(defn)
  end

  def extract_signature({fname, _, args_ast}) do
    args = args_ast |> Enum.map(&X32Remote.Commands.extract_arg_name/1)
    {fname, args}
  end

  def extract_arg_name({arg, _, nil}), do: arg
  def extract_arg_name({:=, _, [_, {arg, _, nil}]}), do: arg

  def doc_summary(doc) do
    doc
    |> String.split("\n", parts: 2)
    |> Enum.at(0)
  end
end
