defmodule HubContext.StorageRoom do
  @behaviour HubContext.Toggler

  @toggler Application.get_env(:hub_context, :toggler)

  @error """
  HubContext.StorageRoom requires a module to implement HubContext.Toggler
  behavior and specify it the config so that toggling behaviour can be
  customized to the situation. i.e. Running on the device vs remote via web.

  Define a module that uses the behavior and expected functions

  defmodule MyModule do
    @behavior HubContext.Toggler
    ...
  end

  Then be sure to set the module in your config:

  config :hub_context, :toggler, MyModule
  """


  @impl true
  def read_lock when is_nil(@toggler), do: raise(@error)
  def read_lock, do: apply(@toggler, :read_lock, [])

  @impl true
  def read_lights when is_nil(@toggler), do: raise(@error)
  def read_lights, do: apply(@toggler, :read_lights, [])

  @impl true
  def toggle_lock(_val) when is_nil(@toggler), do: raise(@error)
  def toggle_lock(val), do: apply(@toggler, :toggle_lock, [val])

  @impl true
  def toggle_lights(_val) when is_nil(@toggler), do: raise(@error)
  def toggle_lights(val), do: apply(@toggler, :toggle_lights, [val])
end
