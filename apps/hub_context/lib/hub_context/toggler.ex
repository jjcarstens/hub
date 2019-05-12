defmodule HubContext.Toggler do
  @type toggle_value :: :on | :off | :locked | :unlocked | 1 | 0

  @callback read_lock() :: :locked | :unlocked
  @callback read_lights() :: :on | :off

  @callback toggle_lights(toggle_value()) :: toggle_value() | :bad_toggle_value
  @callback toggle_lock(toggle_value()) :: toggle_value() | :bad_toggle_value
end
