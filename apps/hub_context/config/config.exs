use Mix.Config

config :hub_context, ecto_repos: [HubContext.Repo]

import_config("#{Mix.env()}.exs")
