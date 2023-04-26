defmodule X32R.MockClient do
  use GenStage
  alias OSC.Message

  defmodule State do
    @enforce_keys [:reply_mode]
    defstruct(
      requests: :queue.new(),
      replies: :queue.new(),
      reply_mode: nil,
      waiting: nil
    )
  end

  def start_link(opts) do
    {reply_mode, opts} = Keyword.pop(opts, :reply_mode, :all)
    GenStage.start_link(__MODULE__, reply_mode, opts)
  end

  # Flush all requests (i.e. outbound UDP) as a list.
  def requests(pid), do: GenStage.call(pid, :flush_requests)
  # Pop the next request if available, or wait until a request is sent and return it.
  def next_request(pid), do: GenStage.call(pid, :next_request)
  # Pretend that we received a reply.
  # All replies will be dumped as events the next time `:send_message` is cast.
  # This can safely be called even if the Session has not connected to the MockClient yet.
  def mock_reply(pid, %Message{} = msg), do: GenStage.cast(pid, {:mock_reply, msg})

  def wait_requests(pid, count) do
    1..count
    |> Enum.map(fn _ -> next_request(pid) end)
  end

  @impl true
  def init(reply_mode) when reply_mode in [:all, :one] do
    {:producer, %State{reply_mode: reply_mode}}
  end

  # Dump requests and clear the requests queue.
  @impl true
  def handle_call(:flush_requests, _from, state) do
    {:reply, state.requests |> :queue.to_list(), [], %State{state | requests: :queue.new()}}
  end

  # Pop a single request from the queue, or wait if empty.
  @impl true
  def handle_call(:next_request, from, state) do
    case state.requests |> :queue.out() do
      {{:value, msg}, rest} ->
        {:reply, msg, [], %State{state | requests: rest}}

      {:empty, _} ->
        {:noreply, [], state |> set_waiting(from)}
    end
  end

  # Append an inbound reply to the queue.
  # This will be popped as an event the next time a `:send_message` cast is received.
  @impl true
  def handle_cast({:mock_reply, msg}, state) do
    {:noreply, [], %State{state | replies: :queue.in(msg, state.replies)}}
  end

  # Pretend to send a message.  This will either reply to our
  # currently waiting `:next_request` caller, or will append it
  # to the requests queue.
  @impl true
  def handle_cast({:send_message, packet}, state) do
    msg = Message.parse(packet)

    state =
      case state.waiting do
        {_, _} = from ->
          GenStage.reply(from, msg)
          %State{state | waiting: nil}

        nil ->
          %State{state | requests: :queue.in(msg, state.requests)}
      end

    case state.reply_mode do
      :all ->
        {:noreply, :queue.to_list(state.replies), %State{state | replies: :queue.new()}}

      :one ->
        {events, replies} = state.replies |> maybe_pop_event()
        {:noreply, events, %State{state | replies: replies}}
    end
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  defp set_waiting(%State{waiting: nil} = state, {_, _} = from), do: %State{state | waiting: from}
  defp set_waiting(%State{waiting: {_, _}}, _), do: raise("double wait on MockClient")

  defp maybe_pop_event(replies) do
    case :queue.out(replies) do
      {{:value, msg}, queue} -> {[msg], queue}
      {:empty, queue} -> {[], queue}
    end
  end
end
