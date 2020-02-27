defmodule Atm.Scene.Info do
  use Atm.Scene

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
         |> button("VintageNet.info", id: :vn_info, theme: :light, t: get_t({20, 60}))
         |> button("IP addresses", id: :ips, theme: :light, t: get_t({200, 60}))
         |> button("Revert", id: :revert, theme: :light, t: get_t({350, 60}))
         |> text("", id: :text_box, t: get_t({20, 130}))
         |> Nav.add_to_graph(%{title: "Info"})

  @impl true
  def init(user, _opts) do
    kv = Nerves.Runtime.KV.get_all_active()

    graph = Graph.modify(@graph, :text_box, &text(&1, "#{inspect(kv, pretty: true)}"))

    # user = user || Atm.Session.current_user()

    {:ok, %{graph: graph}, push: graph}
  end

  @impl true
  def filter_event(e, _, state) do
    Atm.Session.tick()
    handle_filter(e, state)
  end

  defp handle_filter({:click, :ips}, state) do
    data =
      VintageNet.match(["interface", :_, "addresses"])
      |> Enum.reject(&match?({[_, "lo" <> _, _], _}, &1))

    graph = Graph.modify(state.graph, :text_box, &text(&1, "#{inspect(data, pretty: true)}"))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp handle_filter({:click, :revert}, state) do
    Nerves.Runtime.revert()
    {:halt, state}
  end

  defp handle_filter(_, state) do
    {:noreply, state}
  end
end
