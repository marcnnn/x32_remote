defmodule X32Remote.Commands.InfoTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands

  test "info/1" do
    {:ok, client, session} = setup_mock_session()

    info = ["V2.07", "osc-server", "X32RACK", "4.06-8"]
    MockClient.mock_reply(client, %Message{path: "/info", args: info})

    assert Commands.Info.info(session) == info

    assert [msg] = MockClient.requests(client)
    assert msg == %Message{path: "/info"}
  end

  test "xinfo/1" do
    {:ok, client, session} = setup_mock_session()

    xinfo = ["192.168.1.1", "My Mixer", "X32RACK", "4.06-8"]
    MockClient.mock_reply(client, %Message{path: "/xinfo", args: xinfo})

    assert Commands.Info.xinfo(session) == xinfo

    assert [msg] = MockClient.requests(client)
    assert msg == %Message{path: "/xinfo"}
  end

  test "status/1" do
    {:ok, client, session} = setup_mock_session()

    status = ["active", "192.168.1.1", "My Mixer"]
    MockClient.mock_reply(client, %Message{path: "/status", args: status})

    assert Commands.Info.status(session) == status

    assert [msg] = MockClient.requests(client)
    assert msg == %Message{path: "/status"}
  end
end
