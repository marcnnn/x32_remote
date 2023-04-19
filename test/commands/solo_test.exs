defmodule X32Remote.Commands.SoloTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Solo

  test "solo?/2 returns true if solosw/## is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/-stat/solosw/01", args: [1]})
    assert Solo.solo?(session, "ch/01") == true
  end

  test "solo?/2 returns false if solosw/## is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/-stat/solosw/02", args: [0]})
    assert Solo.solo?(session, "ch/02") == false
  end

  test "enable_solo/2 sets solosw/## to 1" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Solo.enable_solo(session, "ch/03")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/03", args: [1]}
  end

  test "disable_solo/2 sets solosw/## to 0" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Solo.disable_solo(session, "ch/04")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/04", args: [0]}
  end

  test "solo functions work with other channel types" do
    {:ok, client, session} = setup_mock_session()

    assert :ok = Solo.enable_solo(session, "auxin/05")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/37", args: [1]}
    assert :ok = Solo.enable_solo(session, "fxrtn/06")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/46", args: [1]}
    assert :ok = Solo.enable_solo(session, "bus/07")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/55", args: [1]}
    assert :ok = Solo.enable_solo(session, "mtx/02")
    assert MockClient.next_request(client) == %Message{path: "/-stat/solosw/66", args: [1]}
  end

  test "any_solo?/1 returns true if stat/solo is 1" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/-stat/solo", args: [1]})
    assert Solo.any_solo?(session) == true
  end

  test "any_solo?/1 returns false if stat/solo is 0" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/-stat/solo", args: [0]})
    assert Solo.any_solo?(session) == false
  end

  test "clear_solo/1 sends clearsolo action" do
    {:ok, client, session} = setup_mock_session()
    assert :ok = Solo.clear_solo(session)
    assert MockClient.next_request(client) == %Message{path: "/-action/clearsolo", args: [1]}
  end
end
