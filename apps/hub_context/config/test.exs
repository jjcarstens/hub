use Mix.Config

config :hub_context, HubContext.Repo,
  username: "postgres",
  password: "",
  database: "hub_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
