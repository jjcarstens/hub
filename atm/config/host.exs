import Config

config :atm, :viewport, %{
  name: :main_viewport,
  default_scene: {Atm.Scene.Splash, nil},
  size: {480, 800},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :atm"]
    }
  ]
}

config :exsync,
  reload_timeout: 75,
  reload_callback: {ScenicLiveReload, :reload_current_scene, []}
