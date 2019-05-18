use Mix.Config

config :hub_api, auth: false

config :hub_api, HubApi.Endpoint,
  code_reloader: true,
  check_origin: false,
  debug_errors: true,
  http: [port: 4000],
  watchers: []

config :hub_context, HubContext.Repo,
  hostname: "localhost",
  username: "postgres",
  database: "hub_db"

config :logger, :console, format: "[$level] $message\n"

config :phoenix,
  stacktrace_depth: 20,
  plug_init_mode: :runtime
