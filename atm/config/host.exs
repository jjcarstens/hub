import Config

config :atm, :viewport, %{
  name: :main_viewport,
  default_scene: {Atm.Scene.Crosshair, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :atm"]
    }
  ]
}
