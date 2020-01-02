defmodule HubApi.StorageRoomController do
  use HubApi, :controller

  def index(conn, _params) do
    conn
    |> json(%{lock: read("lock"), lights: read("lights")})
  end

  def show(conn, %{"type" => type}) do
    read(type)
    |> build_response(conn)
  end

  def update(conn, %{"type" => type, "toggle" => toggle}) do
    toggle(type, toggle)
    |> build_response(conn)
  end

  defp build_response(result, conn) do
    case result do
      {:error, msg} ->
        put_status(conn, :bad_request) |> json(%{error: msg})
      :bad_toggle_value ->
        put_status(conn, :bad_request) |> json(%{error: "bad toggle value"})
      {true, val} ->
        json(conn, val)
      val ->
        json(conn, val)
    end
  end

  defp read("lock"), do: HubContext.StorageRoom.read_lock()
  defp read("lights"), do: HubContext.StorageRoom.read_lights()
  defp read("motion_ignored"), do: HubContext.StorageRoom.motion_ignored?()
  defp read(type), do: {:error, "unknown component in storage room: #{type}"}

  defp toggle("lights", val), do: HubContext.StorageRoom.toggle_lights(val)
  defp toggle("lock", val), do: HubContext.StorageRoom.toggle_lock(val)
  defp toggle("ignore_motion", val) do
    {val, ""} = Integer.parse(val)
    HubContext.StorageRoom.ignore_motion(val)
  end
  defp toggle(type, _val), do: {:error, "unknown component in storage room: #{type}"}
end
