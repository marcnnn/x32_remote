defmodule X32Remote.Commands.MixTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.MainOut

  test "main_stereo_out?/2 returns true if mix/st is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/14/mix/st", args: [1]})
    assert MainOut.main_stereo_out?(session, "ch/14") == true
  end

  test "main_stereo_out?/2 returns false if mix/st is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/15/mix/st", args: [0]})
    assert MainOut.main_stereo_out?(session, "ch/15") == false
  end

  test "enable_main_stereo_out/2 sets mix/st to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = MainOut.enable_main_stereo_out(session, "ch/16")
    assert MockClient.next_request(client) == %Message{path: "/ch/16/mix/st", args: [1]}
  end

  test "disable_main_stereo_out/2 sets mix/st to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = MainOut.disable_main_stereo_out(session, "ch/17")
    assert MockClient.next_request(client) == %Message{path: "/ch/17/mix/st", args: [0]}
  end

  test "main_mono_out?/2 returns true if mix/mono is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/18/mix/mono", args: [1]})
    assert MainOut.main_mono_out?(session, "ch/18") == true
  end

  test "main_mono_out?/2 returns false if mix/mono is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/ch/19/mix/mono", args: [0]})
    assert MainOut.main_mono_out?(session, "ch/19") == false
  end

  test "enable_main_mono_out/2 sets mix/mono to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = MainOut.enable_main_mono_out(session, "ch/20")
    assert MockClient.next_request(client) == %Message{path: "/ch/20/mix/mono", args: [1]}
  end

  test "disable_main_mono_out/2 sets mix/mono to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = MainOut.disable_main_mono_out(session, "ch/21")
    assert MockClient.next_request(client) == %Message{path: "/ch/21/mix/mono", args: [0]}
  end
end
