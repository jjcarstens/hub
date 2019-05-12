use Mix.Config

config :hub_api, HubApi.Endpoint,
  secret_key_base: System.get_env("API_SECRET_KEY_BASE"),
  render_errors: [view: HubApi.ErrorView, accepts: ~w(json)],
  code_reloader: false,
  url: [host: "api.#{System.get_env("HOST")}"]

config :hub_api, auth: true

# Do not print debug messages in production
config :logger, level: :info
