defmodule X32R.TestCase do
  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, unquote(opts)

      alias OSC.Message
      alias X32R.MockClient
      alias X32Remote.Session
      import X32R.SetupHelpers
    end
  end
end
