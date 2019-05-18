use Mix.Config

config :hub_api, HubApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Kkg0a4kTsKMUM+FgQu5wehO/PC+iXvRPltznzkktV0zSwU4PRdBHK0jx3K80OPkR",
  render_errors: [view: HubApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: HubApi.PubSub, adapter: Phoenix.PubSub.PG2]

config :hub_context, ecto_repos: [HubContext.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
