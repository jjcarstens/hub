# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hub,
  ecto_repos: [Hub.Repo]

# Configures the endpoint
config :hub, HubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KbHqXHkKoMGLqJS9gtKkFUo5ob8OKklq+U9UhlkPhTH9XDx83w2pxGz8VEhfryg1",
  render_errors: [view: HubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hub.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, [callback_params: ["origin"]]}
  ]

# oauth2 uses Poison as serializer default. Chagne to Jason
config :oauth2, serializers: %{"application/json" => Jason}

# Development Facebook Auth
config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "173944326601803",
  client_secret: "c9856440130814aa030f0eb57d556d06"

# Configures Drab
config :drab, HubWeb.Endpoint,
  otp_app: :hub

# Configures default Drab file extension
config :phoenix, :template_engines,
  drab: Drab.Live.Engine

# Configures Drab for webpack
config :drab, HubWeb.Endpoint,
  js_socket_constructor: "window.__socket"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
