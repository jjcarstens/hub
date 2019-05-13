defmodule GenieTest do
  use ExUnit.Case
  doctest Genie

  test "greets the world" do
    assert Genie.hello() == :world
  end
end
