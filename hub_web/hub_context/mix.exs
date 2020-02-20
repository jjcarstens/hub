defmodule HubContext.MixProject do
  use Mix.Project

  def project do
    [
      app: :hub_context,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HubContext.Application, []}
    ]
  end

  defp deps do
    [
      {:atrium, github: "mxenabled/atrium-elixir", branch: "jason"},
      {:ecto_enum, "~> 1.2"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.1"}
    ]
  end
end
