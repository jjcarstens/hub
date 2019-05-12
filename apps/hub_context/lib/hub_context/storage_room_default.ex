defmodule HubContext.StorageRoom.Default do
  @behaviour HubContext.Toggler

  @error """
  HubContext.Toggler behavior not implemented for StorageRoom!

  Define a module that uses the behavior and expected functions

  defmodule MyModule do
    @behavior HubContext.Toggler
    ...
  end

  Then be sure to set the module in your config:

  config :hub_context, :storage_room, MyModule
  """

  @impl true
  def read_lock, do: raise(@error)

  @impl true
  def read_lights, do: raise(@error)

  @impl true
  def toggle_lock(_val), do: raise(@error)

  @impl true
  def toggle_lights(_val), do: raise(@error)
end
