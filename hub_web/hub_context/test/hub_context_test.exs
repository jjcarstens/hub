defmodule HubContextTest do
  use ExUnit.Case
  doctest HubContext

  test "greets the world" do
    assert HubContext.hello() == :world
  end
end
