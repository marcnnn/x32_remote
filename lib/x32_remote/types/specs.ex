defmodule X32Remote.Types.Specs do
  @moduledoc false

  defmacro typespec(:channel) do
    quote do
      @type channel :: X32Remote.Types.Channel.channel()
    end
  end

  defmacro typespec(:volume) do
    quote do
      @type volume :: X32Remote.Types.volume()
    end
  end

  defmacro typespec(:panning) do
    quote do
      @type panning :: X32Remote.Types.panning()
    end
  end

  defmacro typespec(:mono_level) do
    quote do
      @type mono_level :: X32Remote.Types.mono_level()
    end
  end
end
