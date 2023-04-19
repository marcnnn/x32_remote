defmodule X32Remote.Commands.MixTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Mix

  test "muted?/2 returns false if mix/on is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/04/mix/on", args: [1]})
    assert Mix.muted?(session, "ch/04") == false
  end

  test "muted?/2 returns true if mix/on is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/05/mix/on", args: [0]})
    assert Mix.muted?(session, "ch/05") == true
  end

  test "mute/2 sets mix/on to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.mute(session, "ch/06")
    assert MockClient.next_request(client) == %Message{path: "/ch/06/mix/on", args: [0]}
  end

  test "unmute/2 sets mix/on to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.unmute(session, "ch/07")
    assert MockClient.next_request(client) == %Message{path: "/ch/07/mix/on", args: [1]}
  end

  test "fader_get/2 returns mix/fader" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/08/mix/fader", args: [0.5]})
    assert Mix.fader_get(session, "ch/08") == 0.5
  end

  test "fader_set/3 with float sets mix/fader" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.fader_set(session, "ch/09", 0.75)
    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [0.75]}
  end

  test "fader_set/3 with integer sets mix/fader" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.fader_set(session, "ch/09", 512)
    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [512]}
  end
end
