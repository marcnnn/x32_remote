defmodule X32Remote.Helpers.Safes do
  @moduledoc false

  def map_safes_by_name(safes) do
    safes
    |> Enum.flat_map(fn {type, members} ->
      members
      |> Enum.with_index()
      |> Enum.map(fn {name, index} -> {name, {type, index}} end)
    end)
    |> Map.new()
  end
end

defmodule X32Remote.Commands.Safes do
  use X32Remote.Commands

  import Bitwise
  import X32Remote.Types.Channel, only: [to_twodigit: 1]
  import X32Remote.Helpers.Safes

  @safe_params [
    inputs:
      ~w"preamp config eq gate_comp insert groups fader_pan mute"
      |> Enum.map(fn s -> :"input_#{s}" end),
    mxsends:
      1..16
      |> Enum.map(fn n -> :"mix_#{n}_sends" end),
    mxbuses:
      ~w"matrix_sends config eq comp insert groups fader_pan mute"
      |> Enum.map(fn s -> :"mix_bus_#{s}" end),
    console:
      ~w"config solo routing out_patch"
      |> Enum.map(fn s -> :"console_#{s}" end)
  ]

  @safe_channels [
    chan16: 1..16 |> Enum.map(fn n -> "ch/#{to_twodigit(n)}" end),
    chan32: 17..32 |> Enum.map(fn n -> "ch/#{to_twodigit(n)}" end),
    return:
      [
        1..8 |> Enum.map(fn n -> "auxin/#{to_twodigit(n)}" end),
        1..8 |> Enum.map(fn n -> "fxrtn/#{to_twodigit(n)}" end)
      ]
      |> List.flatten(),
    buses: 1..16 |> Enum.map(fn n -> "bus/#{to_twodigit(n)}" end),
    lrmtxdca:
      [
        1..6 |> Enum.map(fn n -> "mtx/#{to_twodigit(n)}" end),
        ["main/st", "main/m"],
        1..8 |> Enum.map(fn n -> "dca/#{to_twodigit(n)}" end)
      ]
      |> List.flatten(),
    effects: 1..8 |> Enum.map(fn n -> "fx/#{to_twodigit(n)}" end)
  ]

  @all_safe_params @safe_params |> Keyword.values() |> List.flatten()
  @all_safe_channels @safe_channels |> Keyword.values() |> List.flatten()

  @empty_safe_params @safe_params |> Enum.map(fn {type, _} -> {type, 0} end)
  @empty_safe_channels @safe_channels |> Enum.map(fn {type, _} -> {type, 0} end)

  @safe_params_map map_safes_by_name(@safe_params)
  @safe_channels_map map_safes_by_name(@safe_channels)

  def all_safe_params, do: @all_safe_params
  def all_safe_channels, do: @all_safe_channels

  defcommand get_safe_params(session) do
    @safe_params
    |> Enum.flat_map(fn {type, params} ->
      [bits] = Session.call_command(session, "/-show/showfile/show/#{type}", [])

      params
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> (2 ** i &&& bits) > 0 end)
      |> Enum.map(fn {p, _} -> p end)
    end)
  end

  defcommand get_safe_channels(session) do
    @safe_channels
    |> Enum.flat_map(fn {type, channels} ->
      [bits] = Session.call_command(session, "/-show/showfile/show/#{type}", [])

      channels
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> (2 ** i &&& bits) > 0 end)
      |> Enum.map(fn {p, _} -> p end)
    end)
  end

  defcommand set_safe_params(session, params) do
    params
    |> Enum.reduce(@empty_safe_params, &apply_safe_param/2)
    |> Enum.each(fn {type, bits} ->
      :ok = Session.cast_command(session, "/-show/showfile/show/#{type}", [bits])
    end)
  end

  defcommand set_safe_channels(session, channels) do
    channels
    |> Enum.reduce(@empty_safe_channels, &apply_safe_channel/2)
    |> Enum.each(fn {type, bits} ->
      :ok = Session.cast_command(session, "/-show/showfile/show/#{type}", [bits])
    end)
  end

  defp apply_safe_param(param, safe_params) do
    case Map.fetch(@safe_params_map, param) do
      {:ok, {type, index}} ->
        Keyword.update!(safe_params, type, fn bits -> bits ||| 2 ** index end)

      :error ->
        raise ArgumentError, "Unknown safe parameter: #{inspect(param)}"
    end
  end

  defp apply_safe_channel(channel, safe_channels) do
    case Map.fetch(@safe_channels_map, channel) do
      {:ok, {type, index}} ->
        Keyword.update!(safe_channels, type, fn bits -> bits ||| 2 ** index end)

      :error ->
        raise ArgumentError, "Unknown safe channel: #{inspect(channel)}"
    end
  end
end
