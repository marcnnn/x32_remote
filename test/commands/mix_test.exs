defmodule X32Remote.MixTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Mix

  test "muted?/2" do
    {:ok, client, session} = setup_mock_session()

    MockClient.mock_reply(client, %Message{path: "/ch/04/mix/on", args: [1]})
    assert Mix.muted?(session, "ch/04") == false

    MockClient.mock_reply(client, %Message{path: "/ch/05/mix/on", args: [0]})
    assert Mix.muted?(session, "ch/05") == true

    assert MockClient.requests(client) == [
             %Message{path: "/ch/04/mix/on"},
             %Message{path: "/ch/05/mix/on"}
           ]
  end

  test "mute/2" do
    {:ok, client, session} = setup_mock_session()

    assert :ok = Mix.mute(session, "ch/06")
    assert MockClient.next_request(client) == %Message{path: "/ch/06/mix/on", args: [0]}
  end

  test "unmute/2" do
    {:ok, client, session} = setup_mock_session()

    assert :ok = Mix.unmute(session, "ch/07")
    assert MockClient.next_request(client) == %Message{path: "/ch/07/mix/on", args: [1]}
  end

  test "fader_get/2" do
    {:ok, client, session} = setup_mock_session()

    MockClient.mock_reply(client, %Message{path: "/ch/08/mix/fader", args: [0.5]})
    assert Mix.fader_get(session, "ch/08") == 0.5

    assert MockClient.requests(client) == [%Message{path: "/ch/08/mix/fader"}]
  end

  test "fader_set/3" do
    {:ok, client, session} = setup_mock_session()

    assert :ok = Mix.fader_set(session, "ch/09", 0.75)
    assert :ok = Mix.fader_set(session, "ch/09", 512)

    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [0.75]}
    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [512]}
  end
end