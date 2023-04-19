defmodule X32Remote.MixerTest do
  # Note that test can only be async as long as it's the ONLY test suite that
  # uses X32Remote.Supervisor.
  use ExUnit.Case, async: true

  alias OSC.Message
  alias X32R.MockServer

  defp start do
    server = start_link_supervised!(MockServer)
    port = MockServer.port(server)

    super_spec = %{
      id: X32Remote.Supervisor,
      start: {X32Remote.Supervisor, :start_link, [{127, 0, 0, 1}, port]}
    }

    supervisor = start_link_supervised!(super_spec)
    {:ok, server, supervisor}
  end

  test "casts commands to server" do
    {:ok, server, _} = start()

    X32Remote.Mixer.set_fader("ch/21", 121)
    X32Remote.Mixer.set_fader("ch/22", 222)
    X32Remote.Mixer.mute("ch/23")
    X32Remote.Mixer.unmute("ch/24")

    assert MockServer.next_request(server) == %Message{path: "/ch/21/mix/fader", args: [121]}
    assert MockServer.next_request(server) == %Message{path: "/ch/22/mix/fader", args: [222]}
    assert MockServer.next_request(server) == %Message{path: "/ch/23/mix/on", args: [0]}
    assert MockServer.next_request(server) == %Message{path: "/ch/24/mix/on", args: [1]}
    assert MockServer.requests(server) == []
  end

  test "calls commands on server and waits for replies" do
    {:ok, server, _} = start()

    info = ["V1.11", "osc", "X32", "4.44-4"]
    MockServer.mock_reply(server, %Message{path: "/info", args: info})
    assert X32Remote.Mixer.info() == info

    status = ["active", "127.0.0.1", "MockServer"]
    MockServer.mock_reply(server, %Message{path: "/status", args: status})
    assert X32Remote.Mixer.status() == status

    MockServer.mock_reply(server, %Message{path: "/ch/32/mix/fader", args: [0.75]})
    assert X32Remote.Mixer.get_fader("ch/32") == 0.75

    assert MockServer.requests(server) == [
             %OSC.Message{path: "/info", args: []},
             %OSC.Message{path: "/status", args: []},
             %OSC.Message{path: "/ch/32/mix/fader", args: []}
           ]
  end
end
