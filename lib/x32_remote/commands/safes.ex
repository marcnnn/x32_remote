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

  def to_typespec(list) do
    list
    |> Enum.reverse()
    |> Enum.reduce(&typespec_or/2)
  end

  defp typespec_or(x, y) do
    quote do
      unquote(x) | unquote(y)
    end
  end
end

defmodule X32Remote.Commands.Safes do
  @moduledoc """
  Commands that query or modify the lists of mixer aspects that are considered "safe".

  These "safe" parameters and channels will not be touched when loading
  programs, i.e. cues, snippets, scenes, or channel presets.  They have no
  effect on saving programs.

  ## Safe channels

  Possible safe channels include:

    * Any channel listed in `X32Remote.Types.Channel`
    * `dca/01` through `dca/08`
    * `fx/01` through `fx/08`

  For a list of all posible safe channels, see `all_safe_channels/0`.

  ## Safe parameters

  These parameters apply to all input channels:

    * `:input_preamp` — head amp / microphone preamp
    * `:input_config` — configuration
    * `:input_eq` — equaliser
    * `:input_gate_comp` — gate / compressor settings
    * `:input_insert` — insert settings
    * `:input_groups` — groups
    * `:input_fader_pan` — fader, panning
    * `:input_mute` — mute
    * `:mix_1_sends` through `:mix_16_sends` — channel sends to each mix bus

  These parameters apply to all mix buses:

    * `:mix_bus_matrix_sends` — bus sends to all matrix buses
    * `:mix_bus_config` — configuration
    * `:mix_bus_eq` — equaliser
    * `:mix_bus_comp` — compressor settings
    * `:mix_bus_insert` — insert settings
    * `:mix_bus_groups` — groups
    * `:mix_bus_fader_pan` — fader, panning
    * `:mix_bus_mute` — mute

  These parameters apply to the mixing console as a whole:

    * `:console_config` — configuration
    * `:console_solo` — solo settings
    * `:console_routing` — routing
    * `:console_out_patch` — output patch

  For a list of all posible safe parameters, see `all_safe_params/0`.
  """

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

  @doc "Returns a list of all possible safe parameters."
  def all_safe_params, do: @all_safe_params
  @doc "Returns a list of all possible safe channels."
  def all_safe_channels, do: @all_safe_channels

  @type safe_param :: X32Remote.Types.Program.safe_param()
  typespec(:channel)

  @doc """
  Queries the list of parameters currently set to "safe".

  Returns the list of parameters, as atoms.

  ## Example

      iex> X32Remote.Commands.Safes.get_safe_params(session)
      [:input_groups, :mix_14_sends, :mix_bus_eq, :console_solo]
  """
  @spec get_safe_params(session) :: [safe_param]
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

  @doc """
  Queries the list of channels currently set to "safe".

  Returns the list of channels, as strings.

  ## Example

      iex> X32Remote.Commands.Safes.get_safe_channels(session)
      ["ch/04", "auxin/06", "fxrtn/02", "bus/04", "main/st", "dca/04", "fx/05"]
  """
  @spec get_safe_channels(session) :: [channel]
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

  @doc """
  Changes the list of parameters currently set to "safe".

  **This completely overwrites the existing safe list.**  Any parameter in
  `params` will be marked as safe, and any parameter **not** in `params` will be
  marked as unsafe.

  If you just want to change the safety of certain parameter(s), without wiping
  out any other safeties already set, you should first run `get_safe_params/1`
  to get the current list, then alter the list and run this function on it.

  Returns `:ok` immediately.  Use `get_safe_params/1` if you need to check if
  your changes occurred.

  ## Example

      iex> X32Remote.Commands.Safes.set_safe_params(session)
      [:input_groups, :mix_14_sends, :mix_bus_eq, :console_solo]
  """
  @spec set_safe_params(session, [safe_param]) :: :ok
  defcommand set_safe_params(session, params) do
    params
    |> Enum.reduce(@empty_safe_params, &apply_safe_param/2)
    |> Enum.each(fn {type, bits} ->
      :ok = Session.cast_command(session, "/-show/showfile/show/#{type}", [bits])
    end)
  end

  @doc """
  Changes the list of channels currently set to "safe".

  **This completely overwrites the existing safe list.**  Any channel in
  `channels` will be marked as safe, and any channel **not** in `channels` will
  be marked as unsafe.

  If you just want to change the safety of certain channel(s), without wiping out
  any other safeties already set, you should first run `get_safe_channels/1` to
  get the current list, then alter the list and run this function on it.

  Returns `:ok` immediately.  Use `get_safe_channels/1` if you need to check if
  your changes occurred.

  ## Example

      iex> X32Remote.Commands.Safes.set_safe_channels(session)
      [:input_groups, :mix_14_sends, :mix_bus_eq, :console_solo]
  """
  @spec set_safe_channels(session, [channel]) :: :ok
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
