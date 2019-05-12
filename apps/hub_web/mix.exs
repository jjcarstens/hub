defmodule HubWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :hub_web,
      version: "0.1.0",
      elixir: "~> 1.8",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HubWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:drab, "~> 0.10"},
      {:ecto_sql, "~> 3.0"},
      {:gettext, "~> 0.11"},
      {:hub_context, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:master_proxy, "~> 0.1"},
      {:phoenix, "~> 1.4.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:ueberauth_facebook, "~> 0.7"}
    ]
  end
end
