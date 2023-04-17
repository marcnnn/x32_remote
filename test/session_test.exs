defmodule X32Remote.SessionTest do
  use X32R.TestCase, async: true

  test "cast_message/2 sends message" do
    {:ok, client, session} = setup_mock_session()

    msg = %Message{path: "/ch/17/mix/fader", args: [1.0]}
    Session.cast_message(session, msg)
    assert ^msg = MockClient.next_request(client)
  end

  test "cast_command/3 creates and sends message" do
    {:ok, client, session} = setup_mock_session()

    Session.cast_command(session, "/main/st/mix/on", [1])
    assert msg = MockClient.next_request(client)
    assert %Message{path: "/main/st/mix/on", args: [1]} = msg
  end

  test "call_message/2 sends message and returns reply message" do
    {:ok, client, session} = setup_mock_session()

    query = %Message{path: "/ch/01/mix/fader"}
    reply = %Message{query | args: [0.75]}

    MockClient.mock_reply(client, reply)
    assert Session.call_message(session, query) == reply
  end

  test "call_command/3 creates and sends message and returns reply arguments" do
    {:ok, client, session} = setup_mock_session()

    reply = %Message{path: "/mtx/03/mix/on", args: [1]}
    MockClient.mock_reply(client, reply)

    assert Session.call_command(session, "/mtx/03/mix/on", []) == [1]
  end

  test "call_* ignores messages for other paths" do
    {:ok, client, session} = setup_mock_session()

    MockClient.mock_reply(client, %Message{path: "/ch/01/mix/fader", args: [0.10]})
    MockClient.mock_reply(client, %Message{path: "/ch/02/mix/fader", args: [0.20]})
    MockClient.mock_reply(client, %Message{path: "/ch/03/mix/fader", args: [0.30]})
    MockClient.mock_reply(client, %Message{path: "/ch/04/mix/fader", args: [0.40]})
    MockClient.mock_reply(client, %Message{path: "/ch/05/mix/fader", args: [0.50]})

    assert Session.call_command(session, "/ch/04/mix/fader") == [0.40]
  end

  test "call_* handles node replies" do
    {:ok, client, session} = setup_mock_session()

    info = "/ch/01/config \"Mic\" 48 MG 1\n"
    MockClient.mock_reply(client, %Message{path: "node", args: [info]})

    assert Session.call_command(session, "/node", ["/ch/01/config"]) == [info]
  end
end
