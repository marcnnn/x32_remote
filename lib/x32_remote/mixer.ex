defmodule X32Remote.Mixer do
  @session __MODULE__.Session

  @moduledoc """
  A convenience wrapper for running X32 commands on a single mixer.

  By default, `X32Remote` will start a supervised mixer session, with a
  registered name of `#{inspect(@session)}`.  This module imports all the
  functions from the `X32Remote.Commands.*` modules, automatically supplying
  that name as the first argument.

  This greatly simplifies the process of issuing commands.  Instead of

      iex> {:ok, client} = ExOSC.Client.start_link(ip: {1,2,3,4}, port: 10023)
      iex> {:ok, session} = X32Remote.Server.start_link(client: client)
      iex> X32Remote.Commands.Mixing.get_fader(session, "ch/01")
      0.5

  Now you can just do

      iex> X32Remote.Mixer.get_fader(session, "ch/01")
      0.5
  """

  require X32Remote.Mixer.Builder

  [
    X32Remote.Commands.Mixing,
    X32Remote.Commands.MainOut,
    X32Remote.Commands.Solo,
    X32Remote.Commands.Info,
    X32Remote.Commands.Setup
  ]
  |> Enum.flat_map(fn module ->
    module.__commands__()
    |> Enum.map(fn {fname, args, summary} -> {module, fname, args, summary} end)
  end)
  |> Enum.each(fn {module, fname, args, summary} ->
    X32Remote.Mixer.Builder.defcurried(module, fname, args, summary, session: @session)
  end)
end
