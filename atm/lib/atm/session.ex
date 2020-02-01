defmodule Atm.Session do
  use GenServer

  alias HubContext.Schema.{Order}

  @sys_brightness "/sys/class/backlight/rpi_backlight/brightness"
  @sys_backlight "/sys/class/backlight/rpi_backlight/bl_power"

  defmodule State do
    defstruct brightness: 65,
              current_user: nil,
              timeout: 36_000_000,
              dimmed: false,
              backlight: :on
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def current_user(), do: GenServer.call(__MODULE__, :current_user)

  def set_brightness(brightness) do
    GenServer.call(__MODULE__, {:set_brightness, brightness})
  end

  def set_user(user) do
    GenServer.call(__MODULE__, {:set_user, user})
  end

  def set_timeout(timeout) do
    GenServer.call(__MODULE__, {:set_timeout, timeout})
  end

  def wake() do
    GenServer.call(__MODULE__, :wake)
  end

  @doc """
  Tick the monitor keep-alive
  """
  def tick(), do: GenServer.cast(__MODULE__, :tick)

  @impl true
  def init(_opts) do
    state = %State{}
    {:ok, state, {:continue, :subscribe}}
  end

  @impl true
  def handle_call({:set_brightness, brightness}, _from, state) do
    new_state = change_brightness(state, brightness)
    {:reply, :ok, new_state, state.timeout}
  end

  def handle_call({:set_user, user}, _from, state) do
    user = HubContext.Repo.preload(user, :orders)
    {:reply, :ok, %{state | current_user: user}}
  end

  def handle_call({:set_timeout, timeout}, _from, state) do
    {:reply, :ok, %{state | timeout: timeout}, timeout}
  end

  def handle_call(:current_user, _from, state) do
    {:reply, state.current_user, state, state.timeout}
  end

  def handle_call(:wake, _from, state) do
    {:reply, :ok, wake(state)}
  end

  @impl true
  def handle_cast(:tick, %{backlight: :off} = state) do
    state =
      change_brightness(state, state.brightness)
      |> change_backlight(:on)

    {:noreply, state, state.timeout}
  end

  def handle_cast(:tick, %{dimmed: true} = state) do
    {:noreply, change_brightness(state, state.brightness), state.timeout}
  end

  def handle_cast(:tick, state) do
    {:noreply, state, state.timeout}
  end

  @impl true
  def handle_continue(:subscribe, state) do
    Phoenix.PubSub.subscribe(LAN, "orders:created")

    {:noreply, state, state.timeout}
  end

  @impl true
  def handle_info(%Order{status: :created} = order, %{current_user: nil} = state) do
    state =
      state
      |> change_backlight(:on)
      |> change_brightness(state.brightness)

    Scenic.ViewPort.set_root(:main_viewport, {Atm.Scene.OrderSplash, order})

    {:noreply, state, state.timeout}
  end

  def handle_info(:timeout, %{dimmed: true} = state) do
    # shut off display
    # clear session
    state = change_backlight(state, :off)
    Scenic.ViewPort.set_root(:main_viewport, {Atm.Scene.Splash, nil})
    {:noreply, %{state | current_user: nil, dimmed: false, backlight: :off}}
  end

  def handle_info(:timeout, state) do
    # Scenic.ViewPort.set_root(:main_viewport, {Atm.Scene.Splash, nil})

    # Dimm low
    change_brightness(state, 20)

    {:noreply, %{state | dimmed: true}, 15_000}
  end

  def handle_info(_msg, state) do
    {:noreply, state, state.timeout}
  end

  defp change_backlight(state, backlight) do
    val = if backlight == :off, do: "1", else: "0"

    if Application.get_env(:atm, :target) != :host do
      File.write(@sys_backlight, val)
    end

    %{state | backlight: backlight}
  end

  defp change_brightness(state, brightness) do
    if Application.get_env(:atm, :target) != :host do
      File.write(@sys_brightness, to_string(brightness))
    end

    %{state | brightness: brightness}
  end

  defp wake(state) do
    state
    |> change_backlight(:on)
    |> change_brightness(state.brightness)
  end
end
