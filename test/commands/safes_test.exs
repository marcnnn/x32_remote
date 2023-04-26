defmodule X32Remote.Commands.SafesTest do
  use X32R.TestCase, async: true

  alias X32Remote.Commands.Safes

  test "get_safe_params/2 returns list of safe parameters" do
    {:ok, client, session} = setup_mock_session(reply_mode: :one)

    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/inputs", args: [68]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/mxsends", args: [2116]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/mxbuses", args: [72]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/console", args: [5]})

    assert Safes.get_safe_params(session) ==
             [
               :input_eq,
               :input_fader_pan,
               :mix_03_sends,
               :mix_07_sends,
               :mix_12_sends,
               :mix_bus_comp,
               :mix_bus_fader_pan,
               :console_config,
               :console_routing
             ]
  end

  test "set_safe_params/2 sends safe parameters as bitwise integers" do
    {:ok, client, session} = setup_mock_session()

    safes = [
      :input_preamp,
      :input_gate_comp,
      :input_insert,
      :mix_02_sends,
      :mix_05_sends,
      :mix_06_sends,
      :mix_10_sends,
      :mix_bus_matrix_sends,
      :console_solo,
      :console_out_patch
    ]

    assert :ok = Safes.set_safe_params(session, Enum.shuffle(safes))

    assert MockClient.wait_requests(client, 4) == [
             %Message{path: "/-show/showfile/show/inputs", args: [25]},
             %Message{path: "/-show/showfile/show/mxsends", args: [562]},
             %Message{path: "/-show/showfile/show/mxbuses", args: [1]},
             %Message{path: "/-show/showfile/show/console", args: [10]}
           ]
  end

  test "get_safe_channels/2 returns list of safe channels" do
    {:ok, client, session} = setup_mock_session(reply_mode: :one)

    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/chan16", args: [28441]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/chan32", args: [14973]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/return", args: [9330]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/buses", args: [809]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/lrmtxdca", args: [36]})
    MockClient.mock_reply(client, %Message{path: "/-show/showfile/show/effects", args: [4]})

    assert Safes.get_safe_channels(session) == ~w{
      ch/01 ch/04 ch/05 ch/09 ch/10 ch/11 ch/12 ch/14 ch/15
      ch/17 ch/19 ch/20 ch/21 ch/22 ch/23 ch/26 ch/28 ch/29 ch/30
      auxin/02 auxin/05 auxin/06 auxin/07
      fxrtn/03 fxrtn/06
      bus/01 bus/04 bus/06 bus/09 bus/10
      mtx/03 mtx/06
      fx/03
    }
  end

  test "set_safe_channels/2 sends safe channels as bitwise integers" do
    {:ok, client, session} = setup_mock_session()

    safes = ~w{
      ch/03 ch/04 ch/07 ch/10
      ch/19 ch/25 ch/26
      fxrtn/02 fxrtn/08
      bus/02 bus/03 bus/05 bus/08 bus/10 bus/11 bus/15 bus/16
      mtx/06 main/st main/m dca/08
      fx/08
    }

    assert :ok = Safes.set_safe_channels(session, Enum.shuffle(safes))

    assert MockClient.wait_requests(client, 6) == [
             %Message{path: "/-show/showfile/show/chan16", args: [588]},
             %Message{path: "/-show/showfile/show/chan32", args: [772]},
             %Message{path: "/-show/showfile/show/return", args: [33280]},
             %Message{path: "/-show/showfile/show/buses", args: [50838]},
             %Message{path: "/-show/showfile/show/lrmtxdca", args: [32992]},
             %Message{path: "/-show/showfile/show/effects", args: [128]}
           ]
  end

  test "any set_safe_params/2 input will result in same get_safe_params/2 output" do
    {:ok, client, session} = setup_mock_session(reply_mode: :one)

    # Generate a randomly-sized list of random safe parameters:
    all = Safes.all_safe_params()
    safes = all |> random_subset()
    # Reply will always be in order:
    ordered_safes = all |> Enum.filter(&(&1 in safes))

    # Set params and record outbound messages:
    assert :ok = Safes.set_safe_params(session, safes)
    assert [_, _, _, _] = messages = MockClient.wait_requests(client, 4)

    # Mock inbound messages and get params:
    messages |> Enum.each(&MockClient.mock_reply(client, &1))
    assert Safes.get_safe_params(session) == ordered_safes
  end

  test "any set_safe_channels/2 input will result in same get_safe_channels/2 output" do
    {:ok, client, session} = setup_mock_session(reply_mode: :one)

    # Generate a randomly-sized list of random safe channels:
    all = Safes.all_safe_channels()
    safes = all |> random_subset()
    # Reply will always be in order:
    ordered_safes = all |> Enum.filter(&(&1 in safes))

    # Set channels and record outbound messages:
    assert :ok = Safes.set_safe_channels(session, safes)
    assert [_, _, _, _, _, _] = messages = MockClient.wait_requests(client, 6)

    # Mock inbound messages and get channels:
    messages |> Enum.each(&MockClient.mock_reply(client, &1))
    assert Safes.get_safe_channels(session) == ordered_safes
  end

  defp random_subset(list) do
    count = Enum.count(list)
    list |> Enum.take_random(:rand.uniform(count) - 1)
  end
end
