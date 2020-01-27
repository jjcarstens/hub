defmodule Genie do
  @behaviour HubContext.StorageRoom

  @high_values ["on", "locked", :on, :locked, 1]
  @low_values ["off", "unlocked", :off, :unlocked, 0]
  @valid_values @high_values ++ @low_values

  defguard valid_value(val) when val in @valid_values

  def ignore_motion(timeout), do: Genie.MotionSensor.ignore(timeout)

  def motion_ignored?(), do: Genie.MotionSensor.ignored?()

  def read_lock, do: GenServer.call(Genie.StorageRelay, :read_lock)

  def read_lights, do: GenServer.call(Genie.StorageRelay, :read_lights)

  def toggle_lock(val) when valid_value(val) do
    GenServer.call(Genie.StorageRelay, {:toggle_lock, val})
  end

  def toggle_lock(_val), do: :bad_toggle_value

  def toggle_lights(val) when valid_value(val) do
    GenServer.call(Genie.StorageRelay, {:toggle_lights, val})
  end

  def toggle_lights(_val), do: :bad_toggle_value
end
