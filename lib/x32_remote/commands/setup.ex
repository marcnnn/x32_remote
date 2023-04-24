defmodule X32Remote.Commands.Setup do
  @moduledoc """
  Commands that query or modify the X32 device's configuration.
  """

  use X32Remote.Commands

  @doc """
  Sets the console's clock, as displayed on the mixer's LCD panel.

  `ndt` is a `NaiveDateTime` representing the time to display.  The X32
  hardware does not appear to have any concept of timezones.

  The only thing the clock seems to be used for is being displayed on the LCD.
  This setting has nothing to do with "clock source", used for digital audio
  synchronisation.

  ## Example

      iex> ndt = NaiveDateTime.local_now()
      ~N[2023-04-23 01:31:11]
      iex> X32Remote.Commands.Setup.set_clock(session, ndt)
      :ok
  """
  defcommand set_clock(session, %NaiveDateTime{} = ndt) do
    Session.cast_command(session, "/-action/setclock", [ndt |> Calendar.strftime("%Y%m%d%H%M%S")])
  end
end
