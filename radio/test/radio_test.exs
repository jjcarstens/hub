defmodule RadioTest do
  use ExUnit.Case
  doctest Radio

  test "greets the world" do
    assert Radio.hello() == :world
  end
end
