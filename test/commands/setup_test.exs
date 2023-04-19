defmodule X32Remote.Commands.SetupTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Setup

  test "clock_set/2 sets clock to formatted date and time" do
    {:ok, client, session} = setup_mock_session()

    assert :ok = Setup.clock_set(session, ~N[2023-04-16 14:15:16])

    assert MockClient.next_request(client) == %Message{
             path: "/-action/setclock",
             args: ["20230416141516"]
           }
  end
end
