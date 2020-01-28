defmodule HubWeb.StorageRoom do
  @behaviour HubContext.StorageRoom

  @high_values ["on", "locked", :on, :locked, 1]
  @low_values ["off", "unlocked", :off, :unlocked, 0]
  @valid_values @high_values ++ @low_values

  @topic "nerves:storage_room"

  defguard valid_value(val) when val in @valid_values

  # TODO: This is all asynchronous. Make ability to get direct
  # read results to use API from web remotely...

  def ignore_motion(timeout) do
    Phoenix.PubSub.broadcast(HubWeb.PubSub, @topic, {:ignore_motion, timeout})
  end

  def motion_ignored?() do
    Phoenix.PubSub.broadcast(HubWeb.PubSub, @topic, {:ignore_motion, false})
  end

  def read_lock do
    Phoenix.PubSub.broadcast_from(HubWeb.PubSub, self(), @topic, {:read, :lock})
  end

  def read_lights do
    Phoenix.PubSub.broadcast_from(HubWeb.PubSub, self(), @topic, {:read, :lights})
  end

  def toggle_lock(val) when valid_value(val) do
    Phoenix.PubSub.broadcast_from(HubWeb.PubSub, self(), @topic, {:toggle, :lock, val})
  end

  def toggle_lock(_val), do: :bad_toggle_value

  def toggle_lights(val) when valid_value(val) do
    Phoenix.PubSub.broadcast_from(HubWeb.PubSub, self(), @topic, {:toggle, :lights, val})
  end

  def toggle_lights(_val), do: :bad_toggle_value
end
