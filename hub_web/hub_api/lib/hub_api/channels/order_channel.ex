defmodule HubApi.OrderChannel do
  use HubApi, :channel

  alias HubContext.{Repo, Schema.User, Users}

  def join("orders:" <> first_name, %{"link" => link}, socket) do
    case Repo.get_by(User, first_name: first_name) do
      nil ->
        {:error, %{order_status: "error", msg: "bad_user"}}
      user ->
        user = Repo.preload(user, :orders)

        order = Enum.find(user.orders, %{status: "new"}, &(link =~ &1.link or &1.link =~ link))

        {:ok, %{order_status: order.status}, assign(socket, :user, user)}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("create_order", payload, socket) do
    # TODO: Broadcast this so scene can be displayed
    case Users.create_order(socket.assigns.user, payload) do
      {:ok, order} ->
        {:reply, {:ok, %{order_status: order.status}}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{order_status: "error", msg: "failed to create order"}}, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (nerves:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end