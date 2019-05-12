defmodule HubWeb.StorageRoomController do
  use HubWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html", lights_state: nil, lock_state: nil)
  end
end
