defmodule X32Remote.Commands.SetupTest do
  use ExUnit.Case, async: true

  alias OSC.Message
  alias ExOSC.MockClient
  alias X32Remote.{Session, Commands}

  test "clock_set/2" do
    {:ok, client} = start_supervised(MockClient)
    {:ok, session} = start_supervised({Session, client: client})

    assert :ok = Commands.Setup.clock_set(session, ~N[2023-04-16 14:15:16])

    assert MockClient.next_request(client) == %Message{
             path: "/-action/setclock",
             args: ["20230416141516"]
           }
  end
end
