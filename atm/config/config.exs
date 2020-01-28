import Config

config :atm, target: Mix.target()

config :hub_context,
  ecto_repos: [HubContext.Repo],
  database: "hub_db"

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1577975236"

config :logger, backends: [RingLogger]

if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
