defmodule HubApi.SelectionController do
  use HubApi, :controller

  alias HubContext.{Schema.Selection, Schema.User, Selections}

  @allowed_types Selection.Type.__valid_values__()

  # This is for the ESP32 to request which LED to light up and indicate
  # whose turn it is for the turn type. So we only need to return
  # the frame number to light up
  def turn_picker(conn, %{"type" => type}) when type in @allowed_types do
    case Selections.select_next_for_type(type) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No eligible users for type: #{type}"})
      selected_user ->
        {:ok, frame_num} = User.FrameLocation.dump(selected_user.frame_location)
        json(conn, %{color: selected_user.color, first_name: selected_user.first_name, frame_num: frame_num})
    end
  end

  def turn_picker(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "type must be one of #{inspect(@allowed_types)}"})
  end
end
