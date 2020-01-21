defmodule Pbx.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    children = [
      Pbx.Nodes,
      {Registry, keys: :unique, name: NodesRegistry}
    ]

    opts = [strategy: :one_for_one, name: Pbx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:from_config, _, _) do
    with nodes <- Application.get_env(:pbx, :nodes, []),
         true <- is_list(nodes) && Enum.all?(nodes, &is_atom/1)
    do
      Logger.info("[Pbx] - Adding nodes from config..")
      Enum.each(nodes, &Pbx.add/1)
    else
      _ -> Logger.warn("[Pbx] Config key :nodes must be a list of atoms")
    end
  end
end
