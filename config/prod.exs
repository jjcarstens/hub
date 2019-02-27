use Mix.Config

secrets = File.read!("config/prod.secrets")
          |> String.split()
          |> Enum.reduce(%{}, fn(str, acc) ->
            [key,val] = String.split(":", trim: true)
            Map.put(acc, String.to_atom(key), val)
          end)

config :hub, HubWeb.Endpoint,
  http: [:inet6, port: secrets[:port] || 4000],
  url: [host: secrets.host],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: secrets.secret_key_base,
  server: true

config :hub, Hub.Repo.
  adapter: Ecto.Adapters.Postgres,
  database: "hub_prod",
  ssl: true,
  pool_size: 2

# Do not print debug messages in production
config :logger, level: :info

# config :gigalixir_getting_started, GigalixirGettingStartedWeb.Endpoint,
#   load_from_system_env: true,
#   http: [port: {:system, "PORT"}], # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
#   server: true, # Without this line, your app will not start the web server!
#   secret_key_base: "${SECRET_KEY_BASE}",
#   url: [host: "${APP_NAME}.gigalixirapp.com", port: 443],
#   cache_static_manifest: "priv/static/cache_manifest.json"

# config :gigalixir_getting_started, GigalixirGettingStarted.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   url: "${DATABASE_URL}",
#   database: "",
#   ssl: true,
#   pool_size: 2 # Free tier db on
