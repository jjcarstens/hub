defmodule HubWeb.Auth do
  use Phoenix.Controller

  def init(_params), do: :ok

  def call(%{request_path: "/auth/facebook" <> _} = conn, _params), do: conn
  def call(%{assigns: %{current_user: _user}} = conn, _params), do: conn
  def call(%{request_path: "/"} = conn, _params), do: conn
  def call(%{request_path: "/login"} = conn, _params), do: conn
  def call(%{request_path: "/logout"} = conn, _params), do: conn
  def call(%{request_path: "/privacy_policy"} = conn, _params), do: conn
  def call(conn, _params) do
    case get_session(conn, :user_id) do
      user_id when is_number(user_id) ->
        assign(conn, :current_user, Hub.Repo.get(Hub.Schema.User, user_id))
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to view this page")
        |> redirect(to: "/login")
        |> halt()
    end
  end
end
