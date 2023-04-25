defmodule X32Remote.Types.Specs do
  @moduledoc false

  defmacro typespec(:channel) do
    quote do
      @type channel :: X32Remote.Types.Channel.channel()
    end
  end
end
