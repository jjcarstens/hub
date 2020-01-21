defmodule HubWeb.StorageRoomLive do
  use HubWeb, :liveview
  require Logger
  alias Phoenix.Socket.Broadcast

  def render(assigns) do
    Phoenix.View.render(HubWeb.StorageRoomView, "index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket) do
      HubWeb.Endpoint.subscribe("nerves:storage_room")
    end

    HubContext.StorageRoom.read_lights()
    HubContext.StorageRoom.read_lock()

    socket =
      socket
      |> assign(:lights_state, :off)
      |> assign(:lights_waiting, false)
      |> assign(:lock_state, :locked)
      |> assign(:lock_waiting, false)

    {:ok, socket}
  end

  def handle_event("toggle_lights", _, socket) do
    val = toggle_val(socket.assigns.lights_state)
    HubContext.StorageRoom.toggle_lights(val)

    {:noreply, assign(socket, :lights_waiting, true)}
  end

  def handle_event("toggle_lock", _, socket) do
    val = toggle_val(socket.assigns.lock_state)
    HubContext.StorageRoom.toggle_lock(val)

    {:noreply, assign(socket, :lock_waiting, true)}
  end

  def handle_info(%Broadcast{event: "lights_update", payload: %{"lights_state" => state}}, socket) do
    {:noreply, assign_state(socket, :lights, state)}
  end

  def handle_info({:lights, state}, socket) do
    {:noreply, assign_state(socket, :lights, state)}
  end

  def handle_info(%Broadcast{event: "lock_update", payload: %{"lock_state" => state}}, socket) do
    {:noreply, assign_state(socket, :lock, state)}
  end

  def handle_info({:lock, state}, socket) do
    {:noreply, assign_state(socket, :lock, state)}
  end

  def handle_info({:toggle, type, _val}, socket) do
    socket = assign(socket, String.to_existing_atom("#{type}_waiting"), true)
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp assign_state(socket, key, state) do
    socket
    |> assign(String.to_existing_atom("#{key}_state"), state)
    |> assign(String.to_existing_atom("#{key}_waiting"), false)
  end

  defp toggle_val("off"), do: "on"
  defp toggle_val("on"), do: "off"
  defp toggle_val("locked"), do: "unlocked"
  defp toggle_val("unlocked"), do: "locked"
  defp toggle_val(:off), do: "on"
  defp toggle_val(:on), do: "off"
  defp toggle_val(:locked), do: "unlocked"
  defp toggle_val(:unlocked), do: "locked"
end
