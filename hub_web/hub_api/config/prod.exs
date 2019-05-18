use Mix.Config

config :hub_api, HubApi.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4001],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
