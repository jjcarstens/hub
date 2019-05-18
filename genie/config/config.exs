use Mix.Config

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  provisioning: :nerves_hub

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

config :logger, backends: [RingLogger]

##
# SSH access
#
keys = [Path.join([System.user_home!(), ".ssh", "id_rsa.pub"])]
       |> Enum.filter(&File.exists?/1)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

##
# Setup Networking
passcode = File.read!(".wifi_passcode") |> String.trim

# Setting the node_name will enable Erlang Distribution.
# Only enable this for prod if you understand the risks.
node_name = if Mix.env() != :prod, do: "genie"

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "lamp.local",
  node_name: node_name,
  node_host: :mdns_domain

config :nerves_network,
  regulatory_domain: "US"

config :nerves_network, :default,
  wlan0: [
    networks: [
      [ssid: "nunya", psk: "bidness", key_mgmt: :"WPA-PSK"],
      [ssid: "zwei.vier_hurtz", psk: passcode, key_mgmt: :"WPA-PSK"]
    ]
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

config :genie,
  websocket_url: System.get_env("WEBSOCKET_URL") || "ws://localhost:4000/nerves/websocket",
  websocket_token: System.get_env("WEBSOCKET_TOKEN") || "some_token"

# Just reuse the hub_web config that is part of poncho
import_config("../../hub_web/config/config.exs")

config :hub_context, :storage_room, Genie

config :hub_web, HubWeb.Endpoint,
  server: true,
  code_reloader: false

config :hub_web, auth: false

# Setup of mocking and loading of Nerves to be able to run on host
if Mix.target() == :host do
  config :nerves_runtime, :kernel, autoload_modules: false
  config :nerves_runtime, target: "host"

  config :nerves_runtime, Nerves.Runtime.KV.Mock, %{
    "nerves_fw_active" => "a",
    "a.nerves_fw_uuid" => "924d4d6c-c4c5-50c3-aee8-1f6975ecec87",
    "a.nerves_fw_product" => "genie_hub",
    "a.nerves_fw_architecture" => "arm", # arm?
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
end

# Put things outside of source control here
if File.exists?("config/home.secret.exs") do
  import_config "home.secret.exs"
end
