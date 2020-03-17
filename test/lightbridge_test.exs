defmodule LightbridgeTest do
  use ExUnit.Case
  doctest Lightbridge

  test "greets the world" do
    assert Lightbridge.hello() == :world
  end
end
