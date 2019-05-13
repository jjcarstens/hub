defmodule HubApi.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if Application.get_env(:hub_api, :auth, true) do
      token = get_req_header(conn, "x-auth-token") |> Enum.at(0)
      case Phoenix.Token.verify(conn, "api-signing-salt", token, max_age: :infinity) do
        {:ok, _token_hmac} -> conn
        {:error, error} ->
          conn
          |> put_resp_header("content-type", "application/json")
          |> send_resp(401, Jason.encode!(%{error: "token #{error}"}))
          |> halt()
      end
    else
      # no auth required
      conn
    end
  end
end
