defmodule X32Remote.Builder.Commands do
  @moduledoc false

  @shared_moduledoc """
  All functions in this module take the process ID or name of an
  `X32Remote.Session` process as their first argument.  For more convenient
  versions that omit this first argument, see `X32Remote.Mixer`.
  """

  def shared_moduledoc, do: @shared_moduledoc

  defmacro __using__(_opts) do
    quote do
      require X32Remote.Builder.Commands
      import X32Remote.Builder.Commands, only: [defcommand: 2]

      Module.register_attribute(__MODULE__, :commands, accumulate: true)
      Module.register_attribute(__MODULE__, :typespecs, accumulate: true)

      @before_compile X32Remote.Builder.Commands
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @commands_with_specs X32Remote.Builder.Commands.add_specs(@commands, @spec)
      @command_typespecs X32Remote.Builder.Commands.index_typespecs(@type)

      def __commands__, do: @commands_with_specs
      def __typespecs__, do: @command_typespecs
    end
  end

  defmacro defcommand(defn, body) do
    {fname, args} = X32Remote.Builder.Commands.extract_signature(defn)

    quote do
      @commands {
        unquote(fname),
        unquote(args),
        Module.get_attribute(__MODULE__, :doc) |> X32Remote.Builder.Commands.doc_summary()
      }
      def unquote(defn), unquote(body)
    end
  end

  def extract_signature({:when, _, [defn | _]}) do
    extract_signature(defn)
  end

  def extract_signature({fname, _, args_ast}) do
    args = args_ast |> Enum.map(&X32Remote.Builder.Commands.extract_arg_name/1)
    {fname, args}
  end

  def extract_arg_name({arg, _, nil}), do: arg
  def extract_arg_name({:=, _, [_, {arg, _, nil}]}), do: arg

  def doc_summary(nil), do: nil

  def doc_summary({_, doc}) do
    doc
    |> String.split("\n", parts: 2)
    |> Enum.at(0)
  end

  def add_specs(commands, specs) do
    by_fname =
      specs
      |> Enum.map(&extract_spec/1)
      |> Enum.group_by(&get_spec_name/1)

    commands
    |> Enum.map(fn
      {fname, args, summary} ->
        {fname, args, summary, Map.get(by_fname, fname, [])}
    end)
  end

  defp extract_spec({:spec, spec, _}), do: spec
  defp get_spec_name({:"::", _, [{fname, _, _} | _]}), do: fname

  def index_typespecs(types) do
    types
    |> Enum.map(&extract_typespec/1)
    |> Map.new(fn ts -> {get_spec_name(ts), ts} end)
  end

  defp extract_typespec({:type, typespec, _}), do: typespec
end
