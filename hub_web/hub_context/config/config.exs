use Mix.Config

config :hub_context, HubContext.Repo,
  database: "hub_db",
  username: "postgres",
  password: "",
  hostname: "localhost"

config :hub_context, ecto_repos: [HubContext.Repo]
