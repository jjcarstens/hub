use Mix.Config

config :hub, HubWeb.Endpoint,
  http: [port: 4000],
  https: [
    port: 4001,
    cipher_suite: :strong,
    otp_app: :hub,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :hub_api, HubApi.Endpoint,
  url: [host: "localhost"],
  http: [port: 4080],
  code_reloader: false

# Watch static and templates for browser reloading.
config :hub, HubWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/hub_web/views/.*(ex)$},
      ~r{lib/hub_web/templates/.*(eex|drab)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure the DB
config :hub_context, HubContext.Repo,
  username: "postgres",
  password: "",
  database: "hub_db",
  hostname: "localhost",
  pool_size: 10
