defmodule Genie.MixProject do
  use Mix.Project

  @all_targets [:rpi3a, :rpi3]

  def project do
    [
      app: :genie,
      version: "0.1.1",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.4"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Genie.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:circuits_uart, "~> 1.3"},
      {:hub_web, path: "../hub_web"},
      {:jason, "~> 1.1"},
      {:keypad, "~> 0.1"},
      {:nerves, "~> 1.4", runtime: false},
      {:nerves_hub, "~> 0.1"},
      {:nerves_runtime, "~> 0.8"},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:websockex, "~> 0.4"},

      # Dependencies for all targets except :host
      {:circuits_gpio, "~> 0.3", targets: @all_targets, override: true},
      {:circuits_spi, "~> 0.1", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi3a, "~> 1.6", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi3, "~> 1.6", runtime: false, targets: :rpi3},
    ]
  end
end
