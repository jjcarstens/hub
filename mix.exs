defmodule Hub.MixProject do
  use Mix.Project

  def project do
    [
      app: :hub,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    []
  end
end
