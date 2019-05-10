use Mix.Config

config :hub, HubWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  http: [:inet6, port: System.get_env("PORT") || 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true,
  url: [host: System.get_env("HOST")]

config :hub_api, HubApi.Endpoint,
  http: [:inet6, port: System.get_env("API_PORT") || 4080],
  secret_key_base: System.get_env("API_SECRET_KEY_BASE"),
  server: true,
  render_errors: [view: HubApi.ErrorView, accepts: ~w(json)],
  code_reloader: false,
  url: [host: System.get_env("HOST")]

config :hub_context, HubContext.Repo,
  pool_size: 2,
  ssl: true,
  url: System.get_env("DATABASE_URL")

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("CLIENT_ID"),
  client_secret: System.get_env("CLIENT_SECRET")

# Do not print debug messages in production
config :logger, level: :info
