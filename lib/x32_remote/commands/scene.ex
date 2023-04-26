defmodule X32Remote.Commands.Scene do
  @moduledoc """
  Commands that operate on mixer scenes.
  """
  use X32Remote.Commands

  import X32Remote.Types.Program

  @type scene :: X32Remote.Types.Program.scene()

  @doc """
  Loads a scene saved in a given slot number.

  Returns `:ok` if the console reports that the scene was successfully loaded.

  Returns `{:error, :not_found}` if there is no scene saved in the given slot.

  ## Concurrency

  **This function is not concurrency-safe.**  If multiple processes are using
  the same `ExOSC.Client` or `X32Remote.Session`, only one of them should be
  attempting to load programs at once.  (This includes other program types,
  like cues, snippets, etc.)  This is a fundamental limitation of the protocol.

  If multiple different types of programs are being loaded at once, this
  function might raise an error.  If multiple scenes are being loaded at once,
  their return values will be unreliable.  (Consider running all your program
  loads through a single `GenServer` to synchronise them.)

  ## Example

      iex> X32Remote.Commands.Scene.load_scene(session, 0)
      :ok
      iex> X32Remote.Commands.Scene.load_scene(session, 90)
      {:error, :not_found}
  """
  @spec load_scene(session, scene) :: :ok | {:error, :not_found}
  defcommand load_scene(session, scene) when is_scene(scene) do
    case Session.call_command(session, "/load", ["scene", scene]) do
      ["scene", 1] -> :ok
      ["scene", 0] -> {:error, :not_found}
      [_, _] -> raise "Concurrent load detected"
    end
  end
end
