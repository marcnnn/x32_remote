defmodule X32Remote.Mixer do
  @session X32Remote.Supervisor.Session

  [
    X32Remote.Commands.Mix,
    X32Remote.Commands.Solo,
    X32Remote.Commands.Info,
    X32Remote.Commands.Setup
  ]
  |> Enum.flat_map(fn module ->
    module.__info__(:functions)
    |> Enum.map(fn {name, arity} -> {module, name, arity} end)
  end)
  |> Enum.each(fn
    {module, name, 1} ->
      def unquote(name)(),
        do: unquote(module).unquote(name)(@session)

    {module, name, 2} ->
      def unquote(name)(a),
        do: unquote(module).unquote(name)(@session, a)

    {module, name, 3} ->
      def unquote(name)(a, b),
        do: unquote(module).unquote(name)(@session, a, b)
  end)
end
