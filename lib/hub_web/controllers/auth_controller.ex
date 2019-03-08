defmodule HubWeb.AuthController do
  use HubWeb, :controller
  plug Ueberauth

  alias Hub.Context.Users

  def callback(%{assigns: %{ueberauth_failure: %{errors: errors}}} = conn, _params) do
    errors
    |> Enum.reduce(conn, fn(e, aconn) -> put_flash(aconn, :error, "#{e.message_key} - #{e.message}") end)
    |> redirect(to: "/")
  end
  def callback(%{assigns: %{ueberauth_auth: %{info: user_info, uid: uid}}} = conn, params) do
    {:ok, user} = user_info
    |> Map.delete(:__struct__)
    |> Map.put(:facebook_id, uid)
    |> Users.find_or_create_by_email()

    origin = params["origin"] || "/"

    conn
    |> configure_session(renew: true)
    |> put_session(:user_id, user.id)
    |> assign(:current_user, user)
    |> put_flash(:info, "#{user.first_name} signed in")
    |> redirect(to: origin)
  end

  def login(conn, params) do
    origin = params["origin"] || "/"
    render(conn, "login.html", origin: URI.encode_www_form(origin))
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def privacy_policy(conn, _params) do
    render conn, "privacy_policy.html"
  end
end
