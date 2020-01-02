defmodule HubContext.Radio do
  @type speed :: :off | :low | :mid | :high
  @type outlet_id :: 1 | 2 | 3
  @type radio_return :: :ok | [:ok]

  @callback fan_light() :: radio_return()
  @callback fan_speed(speed()) :: radio_return()

  @callback outlet_on(outlet_id()) :: radio_return()
  @callback outlet_off(outlet_id()) :: radio_return()

  @error """
  HubContext.Radio must behavior be implemented to interact with radio
  controlled items so that toggling behaviour can be customized to the situation.
  i.e. Running on the device vs remote via web.

  Define a module that uses the behavior and expected functions

  defmodule MyModule do
    @behavior HubContext.Radio
    ...
  end

  Then be sure to set the module in your config:

  config :hub_context, :radio, MyModule
  """

  def fan_light do
    case Application.get_env(:hub_context, :radio) do
      nil -> raise(@error)
      module -> apply(module, :fan_light, [])
    end
  end

  def fan_speed(speed) do
    case Application.get_env(:hub_context, :radio) do
      nil -> raise(@error)
      module -> apply(module, :fan_speed, [speed])
    end
  end

  def outlet_off(outlet_id) do
    case Application.get_env(:hub_context, :radio) do
      nil -> raise(@error)
      module -> apply(module, :outlet_off, [outlet_id])
    end
  end

  def outlet_on(outlet_id) do
    case Application.get_env(:hub_context, :radio) do
      nil -> raise(@error)
      module -> apply(module, :outlet_on, [outlet_id])
    end
  end
end
