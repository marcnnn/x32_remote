defmodule X32Remote.Commands.SceneTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Scene

  test "load_scene/2 returns :ok on success" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/load", args: ["scene", 1]})
    assert :ok = Scene.load_scene(session, 20)
  end

  test "load_scene/2 returns error on failure" do
    {:ok, client, session} = setup_mock_session()
    MockClient.mock_reply(client, %Message{path: "/load", args: ["scene", 0]})
    assert {:error, :not_found} = Scene.load_scene(session, 20)
  end
end
