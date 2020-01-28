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

config :hub_context, HubContext.Repo,
  pool_size: 2,
  ssl: true,
  url:
    "postgresql://gigalixir_admin:pw-c5e3713e-ecbf-4df9-ab2d-459dde521107@104.198.59.86:5432/37f7a230-bcf0-4a3e-a1cd-a4979c7c8386"

config :pbx, nodes: [:"genie@10.0.1.7"]
