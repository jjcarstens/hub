defmodule HubWeb.NervesSocket do
  use Phoenix.Socket

  ## Channels
  channel "nerves:*", HubWeb.NervesChannel

  # performing token verification on connect.
  def connect(%{"token" => token} = params, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "nerves token salt", token, max_age: :infinity) do
      {:ok, nerves_id} ->
        socket = assign(socket, :nerves_id, nerves_id)
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  def connect(_params, socket, _connect_info), do: :error

  def id(socket), do: "nerves:#{socket.assigns.nerves_id}"
end
