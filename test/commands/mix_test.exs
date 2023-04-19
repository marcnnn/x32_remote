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

  test "get_fader/2 returns mix/fader" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/08/mix/fader", args: [0.5]})
    assert Mix.get_fader(session, "ch/08") == 0.5
  end

  test "set_fader/3 with float sets mix/fader" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.set_fader(session, "ch/09", 0.75)
    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [0.75]}
  end

  test "set_fader/3 with integer sets mix/fader" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.set_fader(session, "ch/10", 512)
    assert MockClient.next_request(client) == %Message{path: "/ch/10/mix/fader", args: [512]}
  end

  test "get_panning/2 returns mix/panning" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/11/mix/pan", args: [0.2]})
    assert Mix.get_panning(session, "ch/11") == 0.2
  end

  test "set_panning/3 with float sets mix/panning" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.set_panning(session, "ch/12", 0.25)
    assert MockClient.next_request(client) == %Message{path: "/ch/12/mix/pan", args: [0.25]}
  end

  test "set_panning/3 with integer sets mix/panning" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.set_panning(session, "ch/13", 42)
    assert MockClient.next_request(client) == %Message{path: "/ch/13/mix/pan", args: [42]}
  end

  test "main_stereo_out?/2 returns true if mix/st is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/14/mix/st", args: [1]})
    assert Mix.main_stereo_out?(session, "ch/14") == true
  end

  test "main_stereo_out?/2 returns false if mix/st is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/15/mix/st", args: [0]})
    assert Mix.main_stereo_out?(session, "ch/15") == false
  end

  test "enable_main_stereo_out/2 sets mix/st to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.enable_main_stereo_out(session, "ch/16")
    assert MockClient.next_request(client) == %Message{path: "/ch/16/mix/st", args: [1]}
  end

  test "disable_main_stereo_out/2 sets mix/st to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.disable_main_stereo_out(session, "ch/17")
    assert MockClient.next_request(client) == %Message{path: "/ch/17/mix/st", args: [0]}
  end

  test "main_mono_out?/2 returns true if mix/mono is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/18/mix/mono", args: [1]})
    assert Mix.main_mono_out?(session, "ch/18") == true
  end

  test "main_mono_out?/2 returns false if mix/mono is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/19/mix/mono", args: [0]})
    assert Mix.main_mono_out?(session, "ch/19") == false
  end

  test "enable_main_mono_out/2 sets mix/mono to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.enable_main_mono_out(session, "ch/20")
    assert MockClient.next_request(client) == %Message{path: "/ch/20/mix/mono", args: [1]}
  end

  test "disable_main_mono_out/2 sets mix/mono to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Mix.disable_main_mono_out(session, "ch/21")
    assert MockClient.next_request(client) == %Message{path: "/ch/21/mix/mono", args: [0]}
  end
end
