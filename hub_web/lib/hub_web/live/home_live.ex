defmodule HubWeb.HomeLive do
  use HubWeb, :liveview

  def render(assigns) do
    Phoenix.View.render(HubWeb.HomeView, "index.html", assigns)
  end

  def mount(session, socket) do
    socket =
      assign_new(socket, :current_user, fn -> HubContext.Users.get_by_id(session["user_id"]) end)

    {:ok, socket}
  end

  def handle_event("test", _, socket) do
    {:noreply, put_flash(socket, :info, "wat") |> redirect(to: "/")}
  end
end
