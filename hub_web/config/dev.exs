use Mix.Config

config :hub_api, auth: false

config :hub_api, HubApi.Endpoint,
  url: [host: "localhost"],
  http: [port: System.get_env("API_PORT") || 4080],
  code_reloader: false

# Configure the DB
config :hub_context, HubContext.Repo,
  username: "postgres",
  password: "",
  database: "hub_db",
  hostname: "localhost",
  pool_size: 10

config :hub_web, HubWeb.Endpoint,
  auth: false,
  code_reloader: true,
  check_origin: false,
  debug_errors: true,
  http: [port: System.get_env("PORT") || 4000],
  https: [
    port: System.get_env("HTTPS_PORT") || 4001,
    cipher_suite: :strong,
    otp_app: :hub_web,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/hub_web/views/.*(ex)$},
      ~r{lib/hub_web/templates/.*(eex|drab)$}
    ]
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :phoenix,
  plug_init_mode: :runtime,
  stacktrace_depth: 20
