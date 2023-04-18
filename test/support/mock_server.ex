defmodule X32R.MockServer do
  use GenServer
  alias OSC.Message

  defmodule State do
    @enforce_keys [:socket]
    defstruct(
      socket: nil,
      requests: :queue.new(),
      replies: :queue.new(),
      waiting: nil
    )
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :mock, opts)
  end

  # Get the auto-assigned port the server is listening on.
  def port(pid), do: GenServer.call(pid, :get_port)
  # Flush all received UDP requests as a list.
  def requests(pid), do: GenServer.call(pid, :flush_requests)
  # Pop the next inbound UDP request if available, or wait for the next request and return it.
  def next_request(pid), do: GenServer.call(pid, :next_request)
  # Send out a reply in response to the next incoming request.
  def mock_reply(pid, %Message{} = msg), do: GenServer.cast(pid, {:mock_reply, msg})

  @impl true
  def init(:mock) do
    {:ok, socket} = :gen_udp.open(0, [:binary, {:active, true}])
    {:ok, %State{socket: socket}}
  end

  @impl true
  def handle_call(:get_port, _from, state) do
    {:ok, port} = :inet.port(state.socket)
    {:reply, port, state}
  end

  # Dump requests and clear the requests queue.
  @impl true
  def handle_call(:flush_requests, _from, state) do
    {:reply, state.requests |> :queue.to_list(), %State{state | requests: :queue.new()}}
  end

  # Pop a single request from the queue, or wait if empty.
  @impl true
  def handle_call(:next_request, from, state) do
    case state.requests |> :queue.out() do
      {{:value, msg}, rest} ->
        {:reply, msg, %State{state | requests: rest}}

      {:empty, _} ->
        {:noreply, state |> set_waiting(from)}
    end
  end

  # Append an inbound reply to the queue.
  # This will be popped as an event the next time a `:send_message` cast is received.
  @impl true
  def handle_cast({:mock_reply, msg}, state) do
    {:noreply, %State{state | replies: :queue.in(msg, state.replies)}}
  end

  @impl true
  def handle_info({:udp, _, remote_ip, remote_port, packet}, state) do
    request = Message.parse(packet)

    state =
      case state.waiting do
        {_, _} = from ->
          GenServer.reply(from, request)
          %State{state | waiting: nil}

        nil ->
          %State{state | requests: :queue.in(request, state.requests)}
      end

    :queue.to_list(state.replies)
    |> Enum.each(fn reply ->
      :gen_udp.send(state.socket, {remote_ip, remote_port}, Message.to_packet(reply))
    end)

    {:noreply, %State{state | replies: :queue.new()}}
  end

  defp set_waiting(%State{waiting: nil} = state, {_, _} = from), do: %State{state | waiting: from}
  defp set_waiting(%State{waiting: {_, _}}, _), do: raise("double wait on MockClient")
end
