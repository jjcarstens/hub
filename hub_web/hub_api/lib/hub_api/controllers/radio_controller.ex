defmodule HubApi.RadioController do
  use HubApi, :controller

  alias HubContext.Radio

  def index(conn, _params) do
    conn
    |> json(%{available: ["fan", "outlet"]})
  end

  def fan_light(conn, _params) do
    json(conn, Radio.fan_light())
  end

  def fan_speed(conn, %{"speed" => speed}) do
    json(conn, Radio.fan_speed(speed))
  end

  def outlet(conn, %{"outlet_id" => id, "toggle" => toggle}) do
    response =
      case toggle do
        "on" -> Radio.outlet_on(id)
        "off" -> Radio.outlet_off(id)
      end

    json(conn, response)
  end
end
