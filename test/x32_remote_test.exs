defmodule X32RemoteTest do
  use ExUnit.Case
  doctest X32Remote

  test "greets the world" do
    assert X32Remote.hello() == :world
  end
end
