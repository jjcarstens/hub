use Mix.Config

import_config "../apps/*/config/config.exs"

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
