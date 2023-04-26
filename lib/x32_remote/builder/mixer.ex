defmodule X32Remote.Builder.Mixer do
  @moduledoc false

  defmacro build(modules) do
    quote bind_quoted: [modules: modules] do
      require X32Remote.Commands
      alias X32Remote.Builder

      modules
      |> Enum.map(& &1.__typespecs__())
      |> Enum.reduce(&Map.merge/2)
      |> Map.delete(:session)
      |> Enum.each(fn {key, {module, file, spec}} ->
        @type unquote(X32Remote.Builder.Mixer.typespec_or_reference(module, file, spec))
      end)

      modules
      |> Enum.flat_map(fn module ->
        module.__commands__()
        |> Enum.map(fn {fname, args, summary, spec} -> {module, fname, args, summary, spec} end)
      end)
      |> Enum.each(fn {module, fname, args, summary, spec} ->
        X32Remote.Builder.Mixer.defcurried(module, fname, args, summary, spec, session: @session)
      end)
    end
  end

  defmacro defcurried(module, fname, args, summary, spec, to_replace) do
    quote(
      bind_quoted: [
        module: module,
        fname: fname,
        args: args,
        summary: summary,
        spec: spec,
        to_replace: to_replace
      ]
    ) do
      defn =
        args
        |> X32Remote.Builder.Mixer.remove_args(to_replace)
        |> X32Remote.Builder.Mixer.to_function_call(fname)
        |> Code.string_to_quoted!()

      body =
        args
        |> X32Remote.Builder.Mixer.substitute_args(to_replace)
        |> X32Remote.Builder.Mixer.to_function_call(fname, module)
        |> Code.string_to_quoted!()

      @doc X32Remote.Builder.Mixer.document(module, fname, Enum.count(args), summary)
      spec
      |> Enum.each(fn s ->
        s = X32Remote.Builder.Mixer.substitute_spec(fname, to_replace, s)
        @spec unquote(s)
      end)

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

  def substitute_spec(fname, to_replace, {:"::", ctx1, [{fname, ctx2, args}, rval]}) do
    args = args |> remove_spec_args(to_replace)
    {:"::", ctx1, [{fname, ctx2, args}, rval]}
  end

  defp remove_spec_args(args, to_replace) do
    args
    |> Enum.reject(fn
      {arg, _, _} when is_atom(arg) -> Keyword.has_key?(to_replace, arg)
      _ -> false
    end)
  end

  def typespec_or_reference(module, file, {:"::", ctx, [name, content]} = spec) do
    case content do
      {{:., _, [{:__aliases__, _, [:X32Remote, :Types | _]}, _]}, _, _} ->
        # It's a reference to a type in X32Remote.Types (or a submodule), so that's fine.
        spec

      _ ->
        {name_atom, _, _} = name
        msg = "Typespec `#{name_atom}` should refer to a type in `X32Remote.Types`."
        IO.warn(msg, Keyword.put(ctx, :file, file))

        quote do
          unquote(name) :: unquote(module).unquote(name)
        end
    end
  end
end
