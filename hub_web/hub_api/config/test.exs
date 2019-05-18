use Mix.Config

config :hub_api, HubApi.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
