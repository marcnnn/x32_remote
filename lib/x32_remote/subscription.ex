defmodule X32Remote.Subscription do
  use GenStage
  require Logger

  defmodule State do
    @moduledoc false
    @enforce_keys [:watcher, :path, :result_fun]
    defstruct(
      watcher: nil,
      path: nil,
      result_fun: nil,
      last_result: nil
    )
  end

  alias X32Remote.Watcher

  def start_link(opts) do
    {watcher, opts} = Keyword.pop!(opts, :watcher)
    {command, opts} = Keyword.pop!(opts, :command)
    {args, opts} = Keyword.pop(opts, :args, [])

    {:subscribe, path, result_fun} = apply(command, [:subscribe | args])

    GenStage.start_link(__MODULE__, {watcher, path, result_fun}, opts)
  end

  def refresh(pid) do
    GenStage.cast(pid, :refresh)
  end

  @impl true
  def init({watcher, path, result_fun}) do
    {:producer_consumer,
     %State{
       watcher: watcher,
       path: path,
       result_fun: result_fun
     },
     subscribe_to: [
       {watcher,
        selector: fn
          {_, []} -> false
          {^path, _args} -> true
          {_, _} -> false
        end}
     ]}
  end

  @impl true
  def handle_events(events, {_, _}, state) do
    {results, state} =
      events
      |> Enum.map(fn {_path, args} -> state.result_fun.(args) end)
      |> Enum.flat_map_reduce(state, &handle_one_event/2)

    {:noreply, results, state}
  end

  @impl true
  def handle_cast(:refresh, state) do
    Watcher.refresh(state.watcher, state.path)
    {:noreply, [], state}
  end

  @impl true
  def handle_subscribe(:producer, _, _, state), do: {:automatic, state}
  @impl true
  def handle_subscribe(:consumer, _, _, state) do
    Watcher.refresh(state.watcher, state.path)
    {:automatic, state}
  end

  defp handle_one_event(same, %State{last_result: same} = state) do
    {[], state}
  end

  defp handle_one_event(new, %State{last_result: _old} = state) do
    {[new], %State{state | last_result: new}}
  end
end
