defmodule HubWeb.StorageRoomCommander do
  use Drab.Commander
  require Logger
  alias Phoenix.Socket.Broadcast

  onconnect :connected
  onload :page_loaded

  # Drab Callbacks
  def connected(socket) do
    HubWeb.Endpoint.subscribe("nerves:storage_room")
    watcher_loop(socket)
  end

  def page_loaded(socket) do
    HubWeb.Endpoint.broadcast_from! self(), "nerves:storage_room", "read_lights", %{}
    HubWeb.Endpoint.broadcast_from! self(), "nerves:storage_room", "read_lock", %{}
  end

  defhandler toggle_lights(socket, sender) do
    val = toggle_val(peek!(socket, :lights_state))
    HubWeb.Endpoint.broadcast_from! self(), "nerves:storage_room", "toggle_lights", %{toggle: val}
  end

  defhandler toggle_lock(socket, sender) do
    val = toggle_val(peek!(socket, :lock_state))
    HubWeb.Endpoint.broadcast_from! self(), "nerves:storage_room", "toggle_lock", %{toggle: val}
  end

  defp toggle_val("off"), do: "on"
  defp toggle_val("on"), do: "off"
  defp toggle_val("locked"), do: "unlocked"
  defp toggle_val("unlocked"), do: "locked"

  defp watcher_loop(socket) do
    receive do
      %Broadcast{event: "lights_update", payload: %{"lights_state" => state}} ->
        poke(socket, lights_state: state)
      %Broadcast{event: "lock_update", payload: %{"lock_state" => state}} ->
        poke(socket, lock_state: state)
      wat ->
        Logger.error("[#{__MODULE__}] I'm not sure what this is? - #{inspect(wat)}")
    end
    watcher_loop(socket)
  end
end
