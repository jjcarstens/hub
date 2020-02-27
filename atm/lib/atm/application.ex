defmodule Atm.Application do
  @target Mix.target()

  use Application

  def start(_type, _args) do
    # Hackey start node
    :os.cmd('epmd -daemon')
    ip = Application.get_env(:atm, :ip, "10.0.1.38")
    Node.start(:"banker@#{ip}")

    children =
      [
        {Phoenix.PubSub.PG2, name: LAN},
        {Scenic.Sensor, nil},
        Atm.Magstripe,
        Atm.Session
      ] ++ children_for(@target)

    opts = [strategy: :one_for_one, name: Atm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children_for(:host) do
    main_viewport_config = Application.get_env(:atm, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {ScenicLiveReload, viewports: [main_viewport_config]}
    ]
  end

  def children_for(_target) do
    main_viewport_config = Application.get_env(:atm, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]}
    ]
  end
end
