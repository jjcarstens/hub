defmodule Pbx.Nodes do
  use DynamicSupervisor

  alias Pbx.Node

  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add(node) when is_atom(node) do
    DynamicSupervisor.start_child(__MODULE__, {Pbx.Node, node})
  end

  def remove(node) do
    if npid = find_node(node) do
      DynamicSupervisor.terminate_child(__MODULE__, npid)
    end
  end

  defp find_node(node) do
    Node.via_name(node)
    |> GenServer.whereis()
  end
end
