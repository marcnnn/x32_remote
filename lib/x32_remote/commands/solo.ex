defmodule X32Remote.Commands.Solo do
  @moduledoc """
  Commands that query or modify the solo state of the mixer.

  In addition to the channel names accepted by `X32Remote.Types.Channels`,
  these commands also accept `dca/01` through `dca/08` to listen to DCA groups.
  """

  use X32Remote.Commands

  alias X32Remote.Session
  import X32Remote.Types
  import X32Remote.Types.Channels

  # Unlike most commands that specify a channel, we need to use special ID
  # numbers to specify solo devices.  From the unofficial API document:
  #
  #    01-32: Ch 01-32
  #    33-40: Auxin 1-8
  #    41-48: FxRtn 1-8
  #    49-64: Bus master 01-16
  #    65-70: Matrix 1-6
  #    71:    L/R
  #    72:    Mono/Center
  #    73-80: DCA 1-8
  #
  @solo_ids [
              ch: 1..32,
              auxin: 33..40,
              fxrtn: 41..48,
              bus: 49..64,
              mtx: 65..70,
              dca: 73..80
            ]
            |> Enum.flat_map(fn {prefix, range} ->
              range
              |> Enum.with_index()
              |> Enum.map(fn {id, index} ->
                suffix = to_twodigit(index + 1)
                id = to_twodigit(id)
                {"#{prefix}/#{suffix}", id}
              end)
            end)
            |> Map.new()
            |> Map.merge(%{
              "main/st" => 71,
              "main/m" => 72
            })

  @doc """
  Query if solo is enabled for the given channel.

  ## Example

      iex> X32Remote.Commands.Solo.solo?(session, "ch/05")
      false
      iex> X32Remote.Commands.Solo.enable_solo(session, "ch/05")
      :ok
      iex> X32Remote.Commands.Solo.solo?(session, "ch/05")
      true
  """
  defcommand solo?(session, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.call_command(session, "/-stat/solosw/#{id}", []) |> to_boolean()
  end

  @doc """
  Enables solo for the given channel.

  ## Example

      iex> X32Remote.Commands.Solo.enable_solo(session, "ch/06")
      :ok
      iex> X32Remote.Commands.Solo.solo?(session, "ch/06")
      true
  """
  defcommand enable_solo(session, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.cast_command(session, "/-stat/solosw/#{id}", [1])
  end

  @doc """
  Disables solo for the given channel.

  ## Example

      iex> X32Remote.Commands.Solo.disable_solo(session, "ch/07")
      :ok
      iex> X32Remote.Commands.Solo.solo?(session, "ch/07")
      false
  """
  defcommand disable_solo(session, channel) do
    id = Map.fetch!(@solo_ids, channel)
    Session.cast_command(session, "/-stat/solosw/#{id}", [0])
  end

  @doc """
  Checks if solo is enabled for **any** channel.

  This also corresponds to whether the "Clear Solo" button is flashing on the X32 console.

  ## Example

      iex> X32Remote.Commands.Solo.enable_solo(session, "ch/08")
      :ok
      iex> X32Remote.Commands.Solo.any_solo?(session)
      true
      iex> X32Remote.Commands.Solo.clear_solo(session)
      :ok
      iex> X32Remote.Commands.Solo.any_solo?(session)
      false
  """
  defcommand any_solo?(session) do
    Session.call_command(session, "/-stat/solo", []) |> to_boolean()
  end

  @doc """
  Disables solo for **all** channels.

  This is the same as pressing the "Clear Solo" button on the X32 console.

  ## Example

      iex> X32Remote.Commands.Solo.clear_solo(session)
      :ok
      iex> X32Remote.Commands.Solo.any_solo?(session)
      false
  """
  defcommand clear_solo(session) do
    Session.cast_command(session, "/-action/clearsolo", [1])
  end
end
