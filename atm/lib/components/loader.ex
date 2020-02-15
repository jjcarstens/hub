defmodule Atm.Component.Loader do
  use Scenic.Component

  import Scenic.Primitives

  alias Scenic.Graph

  import Atm.Translator

  @default_phase_time 600

  @impl true
  def verify(data), do: {:ok, data}

  @impl true
  def init(_data, _opts) do
    step = 6.283 / @default_phase_time

    graph =
      Graph.build()
      |> arc({100, 0, step}, stroke: {20, :blue}, t: center(), id: :loader)

    state = %{
      graph: graph,
      phase: :forward,
      step: step
    }

    Process.send_after(self(), :animate, 1)

    {:ok, state, push: state.graph}
  end

  @impl true
  def handle_info(:animate, state) do
    graph = Graph.modify(state.graph, :loader, &do_animate(&1, state.step))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp do_animate(%{data: {size, start, val}} = loader, step)
       when start >= 6.283 and val >= 6.283 do
    Process.send_after(self(), :animate, 100)
    arc(loader, {size, 0, step})
  end

  defp do_animate(%{data: {size, start, val}} = loader, step) when val < 6.283 do
    spin = val / step
    # time = spin - ((spin * 0.99 * step) - 0.001)
    time = :math.pow(5, -spin)

    Process.send_after(self(), :animate, round(time))
    arc(loader, {size, start, val + step})
  end

  defp do_animate(%{data: {size, start, val}} = loader, step) do
    # spin = start / step
    # time = spin - ((spin * 0.99 * step) - 0.001)
    # time = :math.pow(3, -spin)
    Process.send_after(self(), :animate, 1)
    # Process.send_after(self(), :animate, round(time))

    arc(loader, {size, start + step, val})
  end
end
