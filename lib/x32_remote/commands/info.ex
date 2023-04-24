defmodule X32Remote.Commands.Info do
  @moduledoc """
  Commands that fetch basic information from an X32 device.
  """

  use X32Remote.Commands

  alias X32Remote.Session

  @doc """
  Query info about the console and OSC server.

  Returns a four-element list containing:

  * the OSC server version
  * the OSC server name
  * the hardware model name
  * the firmware version number

  ## Example

      iex> X32Remote.Commands.Info.info(session)
      ["V2.07", "osc-server", "X32RACK", "4.06-8"]
  """
  defcommand(info(session), do: Session.call_command(session, "/info", []))

  @doc """
  Query info about the console and network setup.

  Returns a four-element list containing:

  * the console's IP address
  * the assigned name of the console
  * the hardware model name
  * the firmware version number

  ## Example

      iex> X32Remote.Commands.Info.xinfo(session)
      ["192.168.4.5", "My Mixer", "X32RACK", "4.06-8"]
  """
  defcommand(xinfo(session), do: Session.call_command(session, "/xinfo", []))

  @doc """
  Query info about the console's state and network setup.

  Returns a three-element list containing:

  * the console's state
  * the console's IP address
  * the assigned name of the console

  ## Example

      iex> X32Remote.Commands.Info.status(session)
      ["active", "192.168.4.5", "My Mixer"]
  """
  defcommand(status(session), do: Session.call_command(session, "/status", []))
end
