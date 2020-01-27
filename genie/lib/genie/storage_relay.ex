defmodule Genie.StorageRelay do
  use GenServer

  @high_values ["on", "locked", :on, :locked, 1]
  @low_values ["off", "unlocked", :off, :unlocked, 0]
  @valid_values @high_values ++ @low_values

  defguard valid_value(val) when val in @valid_values

  defstruct lock: nil, lights: nil, options: nil

  def start_link(options) do
    state = %__MODULE__{options: options}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    send(self(), :init)
    {:ok, state}
  end

  @impl true
  def handle_call(:read_lights, _from, %{lights: lights} = state) do
    {:reply, do_read(lights, :lights), state}
  end

  @impl true
  def handle_call(:read_lock, _from, %{lock: lock} = state) do
    {:reply, do_read(lock, :lock), state}
  end

  @impl true
  def handle_call({:toggle_lights, val}, _from, %{lights: lights} = state) do
    Circuits.GPIO.write(lights, gpio_val(val))
    new_val = do_read(lights, :lights)
    send_update({:lights, new_val})
    {:reply, new_val, state}
  end

  @impl true
  def handle_call({:toggle_lock, val}, _from, %{lock: lock} = state) do
    Circuits.GPIO.write(lock, gpio_val(val))
    new_val = do_read(lock, :lock)
    send_update({:lock, new_val})
    {:reply, new_val, state}
  end

  @impl true
  def handle_info(:init, state) do
    {:ok, lock_pin} = Circuits.GPIO.open(12, :output)
    {:ok, lights_pin} = Circuits.GPIO.open(16, :output)
    {:noreply, %{state | lock: lock_pin, lights: lights_pin}}
  end

  defp do_read(ref, type) do
    Circuits.GPIO.read(ref)
    |> val_to_atom(type)
  end

  defp gpio_val(val) when val in @low_values, do: 0
  defp gpio_val(val) when val in @high_values, do: 1

  defp val_to_atom(1, :lights), do: :on
  defp val_to_atom(0, :lights), do: :off
  defp val_to_atom(1, :lock), do: :locked
  defp val_to_atom(0, :lock), do: :unlocked

  defp send_update(update) do
    Phoenix.PubSub.broadcast(HubWeb.PubSub, "nerves:storage_room", update)
    send(Genie.Websocket, update)
  end
end
