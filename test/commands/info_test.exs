defmodule X32Remote.Commands.ChannelsTest do
  use ExUnit.Case, async: true

  alias OSC.Message
  alias ExOSC.MockClient
  alias X32Remote.{Session, Commands}

  test "muted?/2" do
    {:ok, client} = start_supervised(MockClient)
    {:ok, session} = start_supervised({Session, client: client})

    MockClient.mock_reply(client, %Message{path: "/ch/04/mix/on", args: [1]})
    assert Commands.Channels.muted?(session, "ch/04") == false

    MockClient.mock_reply(client, %Message{path: "/ch/05/mix/on", args: [0]})
    assert Commands.Channels.muted?(session, "ch/05") == true

    assert MockClient.requests(client) == [
             %Message{path: "/ch/04/mix/on"},
             %Message{path: "/ch/05/mix/on"}
           ]
  end

  test "mute/3" do
    {:ok, client} = start_supervised(MockClient)
    {:ok, session} = start_supervised({Session, client: client})

    assert :ok = Commands.Channels.mute(session, "ch/06", true)
    assert :ok = Commands.Channels.mute(session, "ch/07", false)

    assert MockClient.next_request(client) == %Message{path: "/ch/06/mix/on", args: [0]}
    assert MockClient.next_request(client) == %Message{path: "/ch/07/mix/on", args: [1]}
  end

  test "fader_get/2" do
    {:ok, client} = start_supervised(MockClient)
    {:ok, session} = start_supervised({Session, client: client})

    MockClient.mock_reply(client, %Message{path: "/ch/08/mix/fader", args: [0.5]})
    assert Commands.Channels.fader_get(session, "ch/08") == 0.5

    assert MockClient.requests(client) == [%Message{path: "/ch/08/mix/fader"}]
  end

  test "fader_set/3" do
    {:ok, client} = start_supervised(MockClient)
    {:ok, session} = start_supervised({Session, client: client})

    assert :ok = Commands.Channels.fader_set(session, "ch/09", 0.75)
    assert :ok = Commands.Channels.fader_set(session, "ch/09", 512)

    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [0.75]}
    assert MockClient.next_request(client) == %Message{path: "/ch/09/mix/fader", args: [512]}
  end
end
