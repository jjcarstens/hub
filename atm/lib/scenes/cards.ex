defmodule Atm.Scene.Cards do
  use Atm.Scene

  alias HubContext.{Cards, Repo, Users}

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
         |> button("+ Add Card", id: :add, width: 440, theme: :light, t: get_t({20, 60}))
         |> button(">",
           theme: :primary,
           id: :page_forward,
           t: get_t({242.5, 755}),
           radius: 8,
           width: 65,
           hidden: true
         )
         |> button("<",
           theme: :primary,
           id: :page_back,
           t: get_t({172.5, 755}),
           radius: 8,
           width: 65,
           hidden: true
         )
         |> Nav.add_to_graph(%{title: "Cards"})

  @impl true
  def init(user, _opts) do
    graph = Loader.add_to_graph(@graph)
    user = user || Atm.Session.current_user()

    send(self(), :load)

    {:ok, %{args: %{}, cards: nil, graph: @graph, page: 1, pages: [], user: user, waiting: false},
     push: graph}
  end

  @impl true
  def filter_event({:click, :add}, _, state) do
    state = add_overlay(state)

    {:noreply, state, push: state.graph}
  end

  def filter_event({:click, :close_overlay}, _, state) do
    graph =
      Graph.delete(state.graph, :overlay)
      |> Graph.delete(:loader)

    state = clear_overlay(state)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def filter_event({:click, :create_or_update}, _, state) do
    background =
      case Cards.create_or_update(state.args) do
        {:ok, _} -> :green
        _ -> :error
      end

    Process.send_after(self(), :load, 2000)

    graph = Graph.modify(state.graph, :overlay_background, &update_opts(&1, fill: background))

    {:noreply, %{state | args: %{}, graph: graph}, push: graph}
  end

  def filter_event({:value_changed, :user, id}, _, state) do
    Atm.Session.tick()

    {:noreply, %{state | args: Map.put(state.args, :user_id, id)}}
  end

  def filter_event(_, _, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  @impl true
  def handle_info(:load, state) do
    state =
      %{state | cards: Cards.all()}
      |> paginate()
      |> build_card_list()
      |> clear_overlay()

    {:noreply, state, push: state.graph}
  end

  def handle_info({:magstripe, data}, %{waiting: true} = state) do
    users_list =
      Users.all()
      |> Enum.map(&{&1.first_name, &1.id})
      |> Enum.sort()

    start = if card = Cards.from_magstripe(data), do: card.user_id, else: 1

    args =
      state.args
      |> Map.put(:magstripe, data)
      |> Map.put(:user_id, start)

    graph =
      state.graph
      |> Graph.modify({:field, :magstripe}, &text(&1, data))
      |> Graph.delete(:loader)
      |> Graph.add_to(:overlay, fn g ->
        g
        |> button("Create or Update",
          id: :create_or_update,
          button_font_size: 50,
          theme: :success,
          t: get_t({40, 620})
        )
        |> dropdown({users_list, start}, id: :user, theme: :light, t: get_t({150, 350}))
      end)

    {:noreply, %{state | args: args, graph: graph, waiting: false}, push: graph}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp add_overlay(%{graph: graph} = state) do
    ar_fm = get_font_metrics("ATR", 20)
    s_fm = get_font_metrics("Stripe", 20)

    spec = [
      rect_spec({480, 760}, fill: :black, id: :overlay_background),
      button_spec("X", id: :close_overlay, theme: :light, t: {20, 10}),
      text_spec("ATR", t: {240 - ar_fm.fm_width / 2, 80}),
      text_spec("RFC", t: {240 - ar_fm.fm_width / 2, 150}),
      text_spec("Stripe", t: {240 - s_fm.fm_width / 2, 220}),
      text_spec("", id: {:field, :atr}, t: {20, 80 + ar_fm.font_size + ar_fm.ascent}),
      text_spec("", id: {:field, :rfc}, t: {20, 150 + ar_fm.font_size + ar_fm.ascent}),
      text_spec("", id: {:field, :magstripe}, t: {20, 220 + s_fm.font_size + s_fm.ascent})
    ]

    graph =
      graph
      |> add_specs_to_graph(spec, id: :overlay, t: get_t({0, 58}))
      |> Loader.add_to_graph([], id: :loader)

    Phoenix.PubSub.subscribe(LAN, "magstripe")

    %{state | graph: graph, waiting: true}
  end

  defp add_navigation(graph, current_page, pages) do
    total = map_size(pages)

    graph
    |> Graph.modify(:page_back, &update_opts(&1, hidden: current_page == 1))
    |> Graph.modify(:page_forward, &update_opts(&1, hidden: current_page == total))
  end

  defp build_card_list(%{pages: []} = state), do: state

  defp build_card_list(state) do
    cards =
      state.pages[state.page]
      |> Enum.with_index()
      |> Enum.map(&card_spec/1)

    graph =
      state.graph
      |> add_navigation(state.page, state.pages)
      |> Graph.delete(:cards)
      |> add_specs_to_graph(cards, id: :cards)

    %{state | graph: graph}
  end

  defp card_spec({card, i}) do
    card = Repo.preload(card, :user)

    stripe = String.slice("Stripe: #{card.magstripe}", 0..41) <> " ..."
    title = card.user.first_name
    fm = get_font_metrics(title, 35)

    spec = [
      button_spec("", height: 130, width: 440, theme: :dark, id: {:card, card.id}),
      text_spec(card.user.first_name, font_size: 35, t: {15, 30}),
      text_spec("[admin]", fill: :green, t: {fm.fm_width + fm.ascent, 30}),
      text_spec("ATR: #{card.atr}", t: {15, 60}, font_size: 20),
      text_spec("RFC: #{card.rfc}", t: {15, 85}, font_size: 20),
      text_spec("#{stripe}", t: {15, 110}, font_size: 20)
    ]

    y = 110 + i * 150

    group_spec(spec, t: get_t({20, y}))
  end

  defp clear_overlay(%{graph: graph} = state) do
    graph =
      Graph.delete(graph, :overlay)
      |> Graph.delete(:loader)

    %{state | graph: graph}
  end

  defp paginate(%{cards: cards} = state) do
    pages =
      cards
      |> Enum.chunk_every(4)
      |> Enum.with_index(1)
      |> Enum.into(%{}, fn {v, k} -> {k, v} end)

    %{state | pages: pages}
  end
end
