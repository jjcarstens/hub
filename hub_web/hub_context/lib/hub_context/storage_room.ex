defmodule HubContext.StorageRoom do
  @type toggle_value :: :on | :off | :locked | :unlocked | 1 | 0

  @callback ignore_motion(Integer.t()) :: :ok
  @callback motion_ignored?() :: false | {true, Intger.t()}

  @callback read_lock() :: :locked | :unlocked
  @callback read_lights() :: :on | :off

  @callback toggle_lights(toggle_value()) :: toggle_value() | :bad_toggle_value
  @callback toggle_lock(toggle_value()) :: toggle_value() | :bad_toggle_value

  @error """
  HubContext.StorageRoom must behavior be implemented to interact with lock
  and lights so that toggling behaviour can be customized to the situation.
  i.e. Running on the device vs remote via web.

  Define a module that uses the behavior and expected functions

  defmodule MyModule do
    @behavior HubContext.StorageRoom
    ...
  end

  Then be sure to set the module in your config:

  config :hub_context, :storage_room, MyModule
  """

  def ignore_motion(timeout) do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :ignore_motion, [timeout])
    end
  end

  def motion_ignored? do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :motion_ignored?, [])
    end
  end

  def read_lock do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :read_lock, [])
    end
  end
  def read_lights do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :read_lights, [])
    end
  end

  def toggle_lock(val) do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :toggle_lock, [val])
    end
  end

  def toggle_lights(val) do
    case Application.get_env(:hub_context, :storage_room) do
      nil -> raise(@error)
      module -> apply(module, :toggle_lights, [val])
    end
  end
end
