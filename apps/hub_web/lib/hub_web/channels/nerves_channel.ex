defmodule HubWeb.NervesChannel do
  use HubWeb, :channel

  def join("nerves:" <> _id, _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (nerves:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("lights_update", %{"lights_state" => _} = payload, socket) do
    broadcast_from! socket, "lights_update", payload
    {:noreply, socket}
  end

  def handle_in("lock_update", %{"lock_state" => _} = payload, socket) do
    broadcast_from! socket, "lock_update", payload
    {:noreply, socket}
  end

  def handle_in(_msg, _payload, socket) do
    msg = "bad payload or unknown message"
    {:reply, {:error, %{message: msg}}, socket}
  end
end
