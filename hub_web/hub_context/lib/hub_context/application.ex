defmodule HubContext.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [HubContext.Repo]

    opts = [strategy: :one_for_one, name: HubContext.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
