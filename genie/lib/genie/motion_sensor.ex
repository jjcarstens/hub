defmodule Genie.MotionSensor do
  use GenServer
  require Logger

  defguard is_false_trigger(current, past) when is_nil(past) or ((current - past)/1.0e9) < 3

  defstruct pin: nil, last_timestamp: nil, options: nil

  def start_link(options) do
    state = %__MODULE__{options: options}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    send self(), :init
    {:ok, state}
  end

  def read, do: GenServer.call(__MODULE__, :read)

  @impl true
  def handle_call(:read, _from, %{pin: pin} = state) do
    {:reply, Circuits.GPIO.read(pin), state}
  end

  @impl true
  def handle_info(:init, state) do
    # Maybe set pin from config or allow passing option?
    {:ok, motion_pin} = Circuits.GPIO.open(6, :input)
    Circuits.GPIO.set_interrupts(motion_pin, :both)
    {:noreply, %{state | pin: motion_pin}}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, time, 0}, state) do
    # no motion
    Genie.toggle_lights(:off)
    Genie.toggle_lock(:locked)
    {:noreply, %{state | last_timestamp: time}}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, time, 1}, state) do
    # There is motion!
    Genie.toggle_lights(:on)
    Genie.toggle_lock(:unlocked)
    {:noreply, %{state | last_timestamp: time}}
  end
end
