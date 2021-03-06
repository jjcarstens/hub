defmodule Atm.Scene.SecureKeypad do
  use Atm.Scene

  @graph Graph.build(font: :roboto, font_size: 80)
         |> group(
           fn g ->
             %{
               "1" => [id: 1, t: {0, 0}],
               "2" => [id: 2, t: {45, 0}],
               "3" => [id: 3, t: {90, 0}],
               "4" => [id: 4, t: {0, 40}],
               "5" => [id: 5, t: {45, 40}],
               "6" => [id: 6, t: {90, 40}],
               "7" => [id: 7, t: {0, 80}],
               "8" => [id: 8, t: {45, 80}],
               "9" => [id: 9, t: {90, 80}],
               "*" => [id: "*", t: {0, 120}, width: 41],
               "0" => [id: 0, t: {45, 120}],
               "#" => [id: "#", t: {90, 120}]
             }
             |> Enum.reduce(g, fn
               {title, opts}, graph ->
                 options = [{:theme, :dark}, {:radius, 8} | opts]
                 button(graph, title, options)
             end)
             |> button("<", theme: :warning, id: :backspace, t: {0, 160}, radius: 8, width: 63.5)
             |> button("Enter", theme: :success, id: :enter, t: {67.5, 160}, radius: 8, width: 65)
           end,
           t: get_t({110, 250}),
           scale: 2.0
         )
         |> rect({380, 80}, fill: :blue, id: :result, t: get_t({46, 105}), hidden: true)
         |> text("*", id: :filtered, t: get_t({228, 180}), hidden: true)

  def init(incoming, _opts) do
    state =
      incoming
      |> Map.put(:key_presses, [])
      |> Map.put_new(:redirect, {Atm.Scene.Dashboard, nil})
      |> Map.put_new(:title, "")

    graph =
      @graph
      |> Atm.Component.Nav.add_to_graph(Map.take(state, [:title, :redirect]))

    {:ok, Map.put(state, :graph, graph), push: graph}
  end

  def filter_event({:click, :backspace}, _, state) do
    %{state | key_presses: Enum.drop(state.key_presses, 1)}
    |> update_filtered_passcode()
  end

  def filter_event({:click, :enter}, _, state) do
    check_pin(state)
  end

  def filter_event({:click, button}, _, state) do
    %{state | key_presses: [button | state.key_presses]}
    |> update_filtered_passcode()
  end

  def handle_info(:redirect, state) do
    ViewPort.set_root(:main_viewport, state.redirect)
    {:noreply, state}
  end

  def handle_input(_input, _context, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  defp check_pin(%{order: %{user: %{encrypted_pin: pin} = user}, key_presses: keys} = state) do
    input = Enum.reverse(keys) |> Enum.join()

    color =
      if pin == input do
        maybe_update_order(state.order)
        Atm.Session.set_user(user)

        Process.send_after(self(), :redirect, 2_000)

        :green
      else
        :red
      end

    graph =
      state.graph
      |> Graph.modify(:result, &update_opts(&1, fill: color, hidden: false))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp update_filtered_passcode(%{key_presses: key_presses} = state) do
    Atm.Session.tick()

    hidden =
      Enum.join(key_presses, " ")
      |> String.replace(~r/\S/i, "*")

    size = 240 - byte_size(hidden) * 12

    graph =
      state.graph
      |> Graph.modify(:result, &update_opts(&1, hidden: true))
      |> Graph.modify(:filtered, &text(&1, hidden, hidden: false, t: get_t({size, 180})))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp maybe_update_order(%{status: :created} = order) do
    HubContext.Orders.update(order, %{status: :requested})
  end

  defp maybe_update_order(_state), do: :ignore
end
