defmodule Genie.Numpad do
  use GenServer

  require Logger

  alias Genie.AccessCodes

  @device_name ~r/Microsoft .* Nano Transceiver v2.1$/
  # @cal_btn_name "Microsoft Microsoft� Nano Transceiver v2.1 Consumer Control"

  @timeout 5_000

  def device_name, do: @device_name

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    send(self(), :find)

    {:ok, %{input_event: nil, events: [], path: nil, status: :initializing}}
  end

  @impl true
  def handle_info(:find, state) do
    InputEvent.enumerate()
    |> Enum.find(fn {_, info} -> info.name =~ @device_name end)
    |> case do
      {path, _info} ->
        Logger.info("Found Numpad - starting...")
        {:ok, input_event} = InputEvent.start_link(path)

        # Dont want remove USB to crash us
        Process.unlink(input_event)

        {:noreply, %{state | input_event: input_event, path: path, status: :ready}}

      _ ->
        # Keep waiting for device to be plugged in
        reschedule()

        state =
          if state.status != :no_reader do
            %{state | status: :no_reader}
          else
            state
          end

        {:noreply, state}
    end
  end

  def handle_info({:input_event, path, :disconnect}, %{path: path} = state) do
    reschedule()

    {:noreply, %{state | input_event: nil, path: nil}}
  end

  def handle_info({:input_event, path, [_msc, {:ev_key, :key_esc, 1}]}, %{path: path} = state) do
    {:noreply, %{state | events: []}}
  end

  def handle_info({:input_event, path, [_msc, {:ev_key, :key_backspace, 1}]}, %{path: path, events: events} = state) do
    {:noreply, %{state | events: List.delete_at(events, -1)}, @timeout}
  end

  def handle_info({:input_event, path, [_msc, {:ev_key, :key_numlock, 1}]}, %{path: path} = state) do
    Genie.toggle_lock(:locked)
    Genie.toggle_lights(:off)

    {:noreply, state, @timeout}
  end

  def handle_info({:input_event, path, [_msc, {:ev_key, :key_kpasterisk, 1}]}, %{path: path, events: events} = state) do
    input = Enum.map(events, &normalize_key/1) |> Enum.join

    if AccessCodes.valid?(input) do
      case Genie.read_lights() do
        :off -> Genie.toggle_lights(:on)
        :on -> Genie.toggle_lights(:off)
      end
    end

    {:noreply, state, @timeout}
  end

  def handle_info(
        {:input_event, path, [_msc, {:ev_key, :key_kpenter, 1}]},
        %{path: path, events: events} = state
      )
      when length(events) > 0 do
    input = Enum.map(events, &normalize_key/1) |> Enum.join

    if AccessCodes.valid?(input), do: Genie.toggle_lock(:unlocked)

    {:noreply, state, @timeout}
  end

  def handle_info({:input_event, path, events}, %{path: path} = state) do
    # Only care about key events when depressed (1)
    events = for {:ev_key, e, 1} <- events, do: to_string(e)
    {:noreply, %{state | events: state.events ++ events}, @timeout}
  end

  def handle_info(:timeout, state) do
    {:noreply, %{state | events: []}}
  end

  defp normalize_key(<<"key_kp", key::binary-1>>), do: key

  defp normalize_key("key_kpdot"), do: "."
  defp normalize_key("key_kpplus"), do: "+"
  defp normalize_key("key_kpslash"), do: "/"
  defp normalize_key("key_kpminus"), do: "-"

  defp normalize_key(_), do: nil

  defp reschedule() do
    Process.send_after(self(), :find, 2_000)
  end
end
