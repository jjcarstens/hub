use Mix.Config

# Force token auth for API
config :hub_api, auth: true

config :hub_api, HubApi.Endpoint,
  code_reloader: false,
  render_errors: [view: HubApi.ErrorView, accepts: ~w(json)],
  secret_key_base: System.get_env("API_SECRET_KEY_BASE"),
  server: true,
  url: [host: System.get_env("HOST")]

config :hub_context, HubContext.Repo,
  pool_size: 2,
  ssl: true,
  url: System.get_env("DATABASE_URL")

config :hub_web, HubWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true,
  url: [host: System.get_env("HOST")],
  live_view: [signing_salt: System.get_env("LIVEVIEW_SIGNING_SALT")]

# Do not print debug messages in production
config :logger, level: :info

# Use master_proxy for host routing instead of multi nodes and IP routing
config :master_proxy,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  http: [:inet6, port: System.get_env("PORT") || 4000],
  server: true,
  backends: [
    %{
      host: ~r/api.jjcarstens.com/,
      phoenix_endpoint: HubApi.Endpoint
    },
    %{
      host: ~r/jjcarstens.com/,
      phoenix_endpoint: HubWeb.Endpoint
    }
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("CLIENT_ID"),
  client_secret: System.get_env("CLIENT_SECRET")
