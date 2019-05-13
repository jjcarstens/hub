defmodule HubWeb.Auth do
  use Phoenix.Controller

  alias HubContext.Users

  def init(_params), do: :ok

  def call(%{request_path: "/auth/facebook" <> _} = conn, _params), do: conn
  def call(%{assigns: %{current_user: _user}} = conn, _params), do: conn
  def call(%{request_path: "/"} = conn, _params), do: conn
  def call(%{request_path: "/login"} = conn, _params), do: conn
  def call(%{request_path: "/logout"} = conn, _params), do: conn
  def call(%{request_path: "/privacy_policy"} = conn, _params), do: conn
  def call(conn, _params) do
    with true <- Application.get_env(:hub_web, :auth, true),
         user_id when is_number(user_id) <- get_session(conn, :user_id)
    do
      assign(conn, :current_user, Users.get_by_id(user_id))
    else
      false ->
        conn # auth not required
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to view this page")
        |> redirect(to: "/login?origin=#{URI.encode_www_form(conn.request_path)}")
        |> halt()
    end
  end
end
