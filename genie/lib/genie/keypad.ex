defmodule Genie.Keypad do
  use Keypad, col_pins: [5, 24, 13, 26], row_pins: [17, 27, 22, 23], size: :four_by_four

  require Logger

  @jonjon_code "2486"
  @stephanie_code "2424"

  @impl true
  def handle_keypress(key, %{input: ""} = state) do
    Logger.info("First Keypress: #{key}")
    Process.send_after(self(), :reset, 5000)
    %{state | input: key}
  end

  @impl true
  def handle_keypress("D", %{input: "DD"} = state) do
    # Hit D 3 times to turn everything off
    Logger.warn("Resetting from DDD")
    Genie.toggle_lock(:locked)
    Genie.toggle_lights(:off)
    %{state | input: ""}
  end

  @impl true
  def handle_keypress("D", %{input: input} = state) do
    # Treat D as Enter
    case input do
      @jonjon_code ->
        Logger.info("ACCEPTED: jonjon_code")
        Genie.toggle_lock(:unlocked)
      @stephanie_code ->
        Logger.info("ACCEPTED: stephanie_code")
        Genie.toggle_lock(:unlocked)
      _ ->
        # no good
        :ok
    end

    # Pass on D. May be holding it to reset lights and lock
    %{state | input: input <> "D"}
  end

  @impl true
  def handle_keypress(key, %{input: input} = state) do
    Logger.info("Keypress: #{key}")
    %{state | input: input <> key}
  end

  @impl true
  def handle_info(:reset, state) do
    {:noreply, %{state | input: ""}}
  end
end
