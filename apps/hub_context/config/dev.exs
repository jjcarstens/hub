use Mix.Config

config :hub_context, HubContext.Repo,
  hostname: "localhost",
  username: "postgres",
  database: "hub_db"
