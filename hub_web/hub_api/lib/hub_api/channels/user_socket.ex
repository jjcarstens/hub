defmodule HubApi.UserSocket do
  use Phoenix.Socket

  channel "orders:*", HubApi.OrderChannel

  def connect(params, socket, _connect_info) do
    Application.get_env(:hub_api, :auth, true)
    |> verify_token(params)
    |> case do
      :ok -> {:ok, socket}
      _ -> :error
    end
  end

  def id(_socket), do: nil

  defp verify_token(_auth = false, _params), do: :ok

  defp verify_token(_must_auth, _params) do
    # Eventually Check for a token here maybe?
    :error
  end
end
