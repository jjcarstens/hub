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

config :nerves_runtime, :kernel, autoload_modules: false
config :nerves_runtime, target: "host"

config :nerves_runtime, Nerves.Runtime.KV.Mock, %{
  "nerves_fw_active" => "a",
  "a.nerves_fw_uuid" => "924d4d6c-c4c5-50c3-aee8-1f6975ecec87",
  "a.nerves_fw_product" => "genie_hub",
  # arm?
  "a.nerves_fw_architecture" => "arm",
  "a.nerves_fw_version" => "0.2.0",
  "a.nerves_fw_platform" => "arm",
  "a.nerves_fw_misc" => "extra comments",
  "a.nerves_fw_description" => "Genie controller for home automation fun",
  "nerves_fw_devpath" => "/tmp/fwup_bogus_path",
  "nerves_serial_number" => "test"
}

config :nerves_runtime, :modules, [
  {Nerves.Runtime.KV, Nerves.Runtime.KV.Mock}
]
