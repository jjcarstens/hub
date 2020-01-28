defmodule HubWeb.AdminLive do
  use HubWeb, :liveview

  alias HubContext.Users

  def render(assigns) do
    Phoenix.View.render(HubWeb.AdminView, "index.html", assigns)
  end

  def mount(%{"user_id" => user_id}, socket) do
    socket
    |> assign_new(:current_user, fn -> Users.get_by_id(user_id) end)
    |> validate_admin()
  end

  defp validate_admin(%{assigns: %{current_user: %{role: :admin}}} = socket) do
    {:ok, socket}
  end

  defp validate_admin(socket) do
    {:ok,
     socket
     |> put_flash(:error, "Unauthorized - Must be an admin")
     |> redirect(to: "/")}
  end
end
