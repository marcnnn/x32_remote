defmodule X32Remote.Watcher do
  use GenStage
  require Logger

  defmodule State do
    @moduledoc false
    @enforce_keys [:client]
    defstruct(
      client: nil,
      subscribers: MapSet.new(),
      next_renew: nil
    )
  end

  alias OSC.Message

  # /xremote lasts 10 secs, so renew every 9 secs.
  @renew_time 9_000

  def start_link(opts) do
    {client, opts} = Keyword.pop!(opts, :client)
    GenStage.start_link(__MODULE__, client, opts)
  end

  def refresh(watcher, path) do
    GenStage.cast(watcher, {:refresh, path})
  end

  @impl true
  def init(client) do
    {:producer_consumer, %State{client: client},
     subscribe_to: [client], dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl true
  def handle_events(events, {_, _}, state) do
    events =
      events
      |> Enum.map(fn
        {_, %Message{path: path, args: args}} -> {path, args}
      end)

    {:noreply, events, state}
  end

  @impl true
  def handle_cast({:refresh, path}, state) do
    msg = Message.construct(path, [])
    ExOSC.Client.send_message(state.client, msg)
    {:noreply, [], state}
  end

  @impl true
  def handle_subscribe(:producer, _, _, state), do: {:automatic, state}

  @impl true
  def handle_subscribe(:consumer, _, {pid, _}, state) do
    Process.monitor(pid)
    state = %State{state | subscribers: MapSet.put(state.subscribers, pid)}
    {:automatic, renew(state)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    state = %State{state | subscribers: MapSet.delete(state.subscribers, pid)}
    {:noreply, [], state}
  end

  @impl true
  def handle_info({:renew, ref}, state) do
    state = renew(state, ref)
    {:noreply, [], state}
  end

  defp renew(state, current_renew \\ :ensure_started) do
    cond do
      Enum.empty?(state.subscribers) ->
        %State{state | next_renew: nil}

      state.next_renew && state.next_renew != current_renew ->
        state

      true ->
        msg = Message.construct("/xremote", [])
        ExOSC.Client.send_message(state.client, msg)

        ref = Kernel.make_ref()
        Process.send_after(self(), {:renew, ref}, @renew_time)
        %State{state | next_renew: ref}
    end
  end
end
