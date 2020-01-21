defmodule Pbx do
  defdelegate add(node), to: Pbx.Nodes
  defdelegate remove(node), to: Pbx.Nodes
end
