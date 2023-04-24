defmodule X32Remote.Mixer.Builder do
  @moduledoc false

  defmacro defcurried(module, fname, args, summary, to_replace) do
    quote(
      bind_quoted: [
        module: module,
        fname: fname,
        args: args,
        summary: summary,
        to_replace: to_replace
      ]
    ) do
      defn =
        args
        |> X32Remote.Mixer.Builder.remove_args(to_replace)
        |> X32Remote.Mixer.Builder.to_function_call(fname)
        |> Code.string_to_quoted!()

      body =
        args
        |> X32Remote.Mixer.Builder.substitute_args(to_replace)
        |> X32Remote.Mixer.Builder.to_function_call(fname, module)
        |> Code.string_to_quoted!()

      @doc X32Remote.Mixer.Builder.document(module, fname, Enum.count(args), summary)
      def unquote(defn), do: unquote(body)
    end
  end

  def to_function_call(args, fname) do
    args = args |> Enum.join(", ")
    "#{fname}(#{args})"
  end

  def to_function_call(args, fname, module) do
    inspect(module) <> "." <> to_function_call(args, fname)
  end

  def remove_args(args, to_replace) do
    args
    |> Enum.reject(&Keyword.has_key?(to_replace, &1))
  end

  def substitute_args(args, to_replace) do
    args
    |> Enum.map(&Keyword.get(to_replace, &1, &1))
  end

  def document(module, fname, arity, summary) do
    "#{summary}\n\nSee `#{inspect(module)}.#{fname}/#{arity}`."
  end
end
