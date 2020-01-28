defmodule HubWeb.AuthController do
  use HubWeb, :controller
  plug Ueberauth

  alias HubContext.Users

  def callback(%{assigns: %{ueberauth_failure: %{errors: errors}}} = conn, _params) do
    errors
    |> Enum.reduce(conn, fn e, aconn ->
      put_flash(aconn, :error, "#{e.message_key} - #{e.message}")
    end)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info, uid: uid}}} = conn, params) do
    case [user_info.name =~ ~r/Carstens/i, user_info.name =~ ~r/Jon|Stephanie|Ryan|Fay|Jakob/i] do
      [true, true] ->
        {:ok, user} =
          user_info
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

      _ ->
        conn
        |> put_flash(:error, "Your user is not allowed")
        |> redirect(to: "/")
    end
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
    render(conn, "privacy_policy.html")
  end
end
