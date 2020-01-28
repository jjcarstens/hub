defmodule Atm.Magstripe do
  use GenServer

  alias Scenic.Sensor

  require Logger

  @device_name "HID c216:0180"
  @sensor_id :magstripe

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    send(self(), :find)

    {:ok, %{input_event: nil, events: [], last_read: "", path: nil, status: :initializing}}
  end

  @impl true
  def handle_info(:find, state) do
    InputEvent.enumerate()
    |> Enum.find(fn {_, info} -> info.name == @device_name end)
    |> case do
      {path, _info} ->
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

  def handle_info(
        {:input_event, path, [_msc, {:ev_key, :key_enter, _}]},
        %{path: path, events: events} = state
      )
      when length(events) > 0 do
    last_read = parse_events(events)

    Phoenix.PubSub.broadcast_from!(LAN, self(), "magstripe", {:magstripe, last_read})

    {:noreply, %{state | events: [], last_read: last_read}}
  end

  def handle_info({:input_event, path, events}, %{path: path} = state) do
    # Only care about key events when depressed (1)
    events = for {:ev_key, e, 1} <- events, do: e
    {:noreply, %{state | events: state.events ++ events}}
  end

  @key_descriptors %{
    "equal" => "=",
    "space" => " ",
    "apostrophe" => "'",
    "backslash" => "\\",
    "comma" => ",",
    "dot" => ".",
    "leftbrace" => "[",
    "minus" => "-",
    "rightbrace" => "]",
    "semicolon" => ";",
    "slash" => "/"
  }
  defp normalize_key(key) do
    to_string(key)
    |> String.replace("key_", "")
    |> case do
      <<key::binary-1>> -> key
      key -> Map.fetch!(@key_descriptors, key)
    end
  end

  defp parse_events(events, acc \\ "")

  defp parse_events([], acc), do: acc

  defp parse_events([event | tail], acc) when event in [:key_rightshift, :key_leftshift] do
    [event | tail] = tail
    key = normalize_key(event) |> shift_key()
    parse_events(tail, acc <> key)
  end

  defp parse_events([event | tail], acc) do
    parse_events(tail, acc <> normalize_key(event))
  end

  defp reschedule() do
    Process.send_after(self(), :find, 2_000)
  end

  @key_shifts %{
    "'" => "\"",
    "," => "<",
    "-" => "_",
    "." => ">",
    "/" => "?",
    "0" => ")",
    "1" => "!",
    "2" => "@",
    "3" => "#",
    "4" => "$",
    "5" => "%",
    "6" => "^",
    "7" => "&",
    "8" => "*",
    "9" => "(",
    ";" => ":",
    "=" => "+",
    "[" => "{",
    "\\" => "|",
    "]" => "}"
  }
  defp shift_key(key) do
    if key =~ ~r/^[a-z]$/ do
      String.upcase(key)
    else
      Map.fetch!(@key_shifts, key)
    end
  end
end
