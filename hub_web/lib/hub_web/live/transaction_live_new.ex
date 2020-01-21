defmodule HubWeb.TransactionLive.New do
  use HubWeb, :liveview

  alias HubContext.Transactions

  def render(assigns) do
    Phoenix.View.render(HubWeb.TransactionView, "new.html", assigns)
  end

  def mount(session, socket) do
    socket =
      socket
      |> assign(:changeset, Transactions.changeset(%{}))
      |> assign(:users, users_list())
    {:ok, socket}
  end

  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      Transactions.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"transaction" => params}, socket) do
    case Transactions.create(params) do
      {:ok, transaction} ->
        socket =
          socket
          |> put_flash(:info, "transaction created")
          |> redirect(to: "/admin")

        {:stop, socket}
        
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp users_list() do
    HubContext.Users.all()
    |> Enum.map(& {"#{&1.first_name}", &1.id})
  end
end
