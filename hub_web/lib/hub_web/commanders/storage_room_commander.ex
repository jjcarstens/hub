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
    poke(socket, lights_state: HubContext.StorageRoom.read_lights())
    poke(socket, lock_state: HubContext.StorageRoom.read_lock())
  end

  defhandler toggle_lights(socket, _sender) do
    val = toggle_val(peek!(socket, :lights_state))
    HubContext.StorageRoom.toggle_lights(val)
  end

  defhandler toggle_lock(socket, _sender) do
    val = toggle_val(peek!(socket, :lock_state))
    HubContext.StorageRoom.toggle_lock(val)
  end

  defp toggle_val("off"), do: "on"
  defp toggle_val("on"), do: "off"
  defp toggle_val("locked"), do: "unlocked"
  defp toggle_val("unlocked"), do: "locked"
  defp toggle_val(:off), do: "on"
  defp toggle_val(:on), do: "off"
  defp toggle_val(:locked), do: "unlocked"
  defp toggle_val(:unlocked), do: "locked"

  defp watcher_loop(socket) do
    receive do
      %Broadcast{event: "lights_update", payload: %{"lights_state" => state}} ->
        poke(socket, lights_state: state)
      %Broadcast{event: "lock_update", payload: %{"lock_state" => state}} ->
        poke(socket, lock_state: state)
      {:lights, lights_state} ->
        poke(socket, lights_state: lights_state)
      {:lock, lock_state} ->
        poke(socket, lock_state: lock_state)
      wat ->
        Logger.error("[#{__MODULE__}] I'm not sure what this is? - #{inspect(wat)}")
    end
    watcher_loop(socket)
  end
end
