defmodule Atm.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  import Atm.Translator
  import Atm.Helpers

  @impl true
  def verify(data) when is_map(data) or is_nil(data), do: {:ok, data}
  def verify(_), do: :invalid_data

  @impl true
  def init(state, _opts) do
    state =
      Map.put(state, :graph, Graph.build())
      |> add_title()
      |> maybe_add_admin_dash()
      |> add_logout_or_close()

    {:ok, state, push: state.graph}
  end

  defp add_title(%{graph: graph} = state) do
    title = state[:title] || ""
    %{fm_width: fm_width} = get_font_metrics(title, 40)
    title_x = 240 - fm_width / 2

    graph = text(graph, title, font_size: 40, t: get_t({title_x, 40}))

    %{state | graph: graph}
  end

  defp add_logout_or_close(state) do
    {label, id} =
      if redirect = state[:redirect] do
        {"X", {:redirect, redirect}}
      else
        {"Logout", :logout}
      end

    fm = get_font_metrics(label, 20)
    width = fm.ascent * 2 + fm.fm_width
    x = 465 - width

    graph =
      state.graph
      |> button(label, id: id, radius: 4, theme: :danger, t: get_t({x, 10}))

    %{state | graph: graph}
  end

  defp maybe_add_admin_dash(%{graph: graph} = state) do
    case Atm.Session.current_user() do
      %{role: :admin} ->
        %{ascent: ascent, font_size: fs} = get_font_metrics("Dashboard", 20)
        height = ascent + fs

        y = 12
        x = 30
        y0 = height / 2 + y

        graph =
          graph
          |> triangle({get_t({x / 2, y0}), get_t({x + 2, y}), get_t({x + 2, height + y})},
            stroke: {1, :white},
            join: :bevel
          )
          |> button("Dashboard", theme: :dark, t: get_t({x, y}), id: :admin)
          |> line({get_t({x, y}), get_t({x, y + height - 3})}, stroke: {2, :black})

        %{state | graph: graph}

      _ ->
        state
    end
  end

  @impl true
  def filter_event({:click, :admin}, _, state) do
    ViewPort.set_root(:main_viewport, {Atm.Scene.Dashboard, nil})

    {:halt, state}
  end

  def filter_event({:click, :logout}, _, state) do
    Atm.Session.set_user(nil)
    ViewPort.set_root(:main_viewport, {Atm.Scene.Splash, nil})
    {:halt, state}
  end

  def filter_event({:click, {:redirect, redirect}}, _, state) do
    ViewPort.set_root(:main_viewport, redirect)
    {:halt, state}
  end
end
