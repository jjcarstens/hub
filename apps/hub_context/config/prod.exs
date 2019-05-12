use Mix.Config

config :hub_context, HubContext.Repo,
  pool_size: 2,
  ssl: true,
  url: System.get_env("DATABASE_URL")
