defmodule Genie.Websocket do
  use WebSockex
  require Logger

  @topic "nerves:storage_room"

  def start_link(state) do
    url = Application.get_env(:genie, :websocket_url)
    token = Application.get_env(:genie, :websocket_token)

    WebSockex.start_link("#{url}?token=#{token}", __MODULE__, state,
      name: __MODULE__,
      async: true,
      handle_initial_conn_failure: true
    )
  end

  @impl true
  def handle_connect(_conn, state) do
    send(self(), :join)
    {:ok, state}
  end

  @impl true
  def handle_disconnect(_conn_map, state) do
    Logger.error("Websocket Disconnect: Attempting reconnect")
    {:reconnect, state}
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    Jason.decode!(msg)
    |> handle_message()

    {:ok, state}
  end

  @impl true
  def handle_info({:lights, lights_state}, state) do
    msg =
      %{
        payload: %{lights_state: lights_state},
        event: "lights_update",
        topic: @topic,
        ref: "sdfarewr"
      }
      |> Jason.encode!()

    {:reply, {:text, msg}, state}
  end

  @impl true
  def handle_info({:lock, lock_state}, state) do
    msg =
      %{
        payload: %{lock_state: lock_state},
        event: "lock_update",
        topic: @topic,
        ref: "oihawekjsdv"
      }
      |> Jason.encode!()

    {:reply, {:text, msg}, state}
  end

  @impl true
  def handle_info(:join, state) do
    join_payload =
      %{
        payload: %{},
        event: "phx_join",
        topic: @topic,
        ref: "lbkajldkfjawr",
        join_ref: "oijwpejpasfsf"
      }
      |> Jason.encode!()

    {:reply, {:text, join_payload}, state}
  end

  @impl true
  def handle_cast({:send, frame}, state) do
    {:reply, frame, state}
  end

  defp handle_message(%{"event" => "toggle_lights", "payload" => %{"toggle" => val}}) do
    Genie.toggle_lights(val)
  end

  defp handle_message(%{"event" => "toggle_lock", "payload" => %{"toggle" => val}}) do
    Genie.toggle_lock(val)
  end

  defp handle_message(%{"event" => "read_lights"}) do
    send(self(), {:lights, Genie.read_lights()})
  end

  defp handle_message(%{"event" => "read_lock"}) do
    send(self(), {:lock, Genie.read_lock()})
  end

  defp handle_message(%{
         "event" => "phx_reply",
         "payload" => %{"response" => %{}, "status" => "ok"}
       }) do
    # Just an ack, so nothing to do here
    :ok
  end

  defp handle_message(msg) do
    Logger.warn("Dont know how to handle websocket message: \n#{inspect(msg)}")
  end
end
