defmodule Pbx.Node do
  use GenServer

  def start_link(node) do
    GenServer.start_link(__MODULE__, node, name: via_name(node))
  end

  def via_name(node) do
    {:via, Registry, {NodesRegistry, node}}
  end

  @impl true
  def init(node) do
    Node.monitor(node, true)
    {:ok, node}
  end

  @impl true
  def handle_info({:nodedown, node}, node) do
    Node.monitor(node, true)
    {:noreply, node}
  end
end
