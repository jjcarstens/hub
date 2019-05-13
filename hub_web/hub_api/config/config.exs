# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hub_api, HubApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Kkg0a4kTsKMUM+FgQu5wehO/PC+iXvRPltznzkktV0zSwU4PRdBHK0jx3K80OPkR",
  render_errors: [view: HubApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: HubApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :hub_context, ecto_repos: [HubContext.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
