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
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("lights_update", %{"lights_state" => lights_state}, socket) do
    Phoenix.PubSub.broadcast_from!(HubWeb.PubSub, self(), socket.topic, {:lights, lights_state})
    {:noreply, socket}
  end

  def handle_in("lock_update", %{"lock_state" => lock_state}, socket) do
    Phoenix.PubSub.broadcast_from!(HubWeb.PubSub, self(), socket.topic, {:lock, lock_state})
    {:noreply, socket}
  end

  def handle_in(_msg, _payload, socket) do
    msg = "bad payload or unknown message"
    {:reply, {:error, %{message: msg}}, socket}
  end

  def handle_info({:read, type}, socket) do
    push(socket, "read_#{type}", %{})
    {:noreply, socket}
  end

  def handle_info({:toggle, type, toggle_val}, socket) do
    push(socket, "toggle_#{type}", %{toggle: toggle_val})
    {:noreply, socket}
  end
end
