defmodule Atm.Scene.Cards do
  use Atm.Scene

  alias HubContext.{Cards, Repo, Users}

  import Scenic.Keypad.Components

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
    graph = loader(@graph)
    user = user || Atm.Session.current_user()

    send(self(), :load)

    {:ok, %{args: %{}, cards: nil, graph: @graph, page: 1, pages: [], user: user, waiting: false},
     push: graph}
  end

  @impl true
  def filter_event(event, _, state) do
    Atm.Session.tick()
    handle_event(event, state)
  end

  @impl true
  def handle_info(:clear_pin, %{args: args} = state) do
    state =
      %{state | args: Map.put(args, :pin, "")}
      |> display_pin()

    {:noreply, state, push: state.graph}
  end

  def handle_info(:load, state) do
    Atm.Session.tick()

    cards = Cards.all() |> Enum.map(&Repo.preload(&1, :user))

    state =
      %{state | cards: cards}
      |> paginate()
      |> build_card_list()
      |> clear_overlay()

    {:noreply, state, push: state.graph}
  end

  def handle_info({:magstripe, data}, %{waiting: true} = state) do
    Atm.Session.tick()

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
          t: {40, 620}
        )
        |> dropdown({users_list, start}, id: :user, theme: :light, t: {150, 350})
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
      |> loader(id: :loader, t: center())

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

  defp card_overlay(%{graph: graph} = state, card_id) do
    card = Enum.find(state.cards, &(&1.id == card_id))

    ar_fm = get_font_metrics("ATR", 20)
    s_fm = get_font_metrics("Stripe", 20)

    fm = Scenic.Cache.Static.FontMetrics.get!(:roboto)

    stripe = FontMetrics.wrap(card.magstripe, 420, 20, fm)

    spec = [
      rect_spec({480, 760}, fill: :black, id: :overlay_background),
      button_spec("X", id: :close_overlay, theme: :light, t: {20, 10}),
      text_spec("ATR", t: {240 - ar_fm.fm_width / 2, 80}),
      text_spec("RFC", t: {240 - ar_fm.fm_width / 2, 150}),
      text_spec("Stripe", t: {240 - s_fm.fm_width / 2, 220}),
      text_spec("#{card.atr}", id: {:field, :atr}, t: {20, 80 + ar_fm.font_size + ar_fm.ascent}),
      text_spec("#{card.rfc}", id: {:field, :rfc}, t: {20, 150 + ar_fm.font_size + ar_fm.ascent}),
      text_spec("#{stripe}",
        id: {:field, :magstripe},
        t: {20, 220 + s_fm.font_size + s_fm.ascent},
        font_size: 20
      ),
      rect_spec({40, 100}, hidden: true, id: :pin_status),
      text_spec("", id: :pin, hidden: true, font_size: 80),
      keypad_spec(theme: :dark, t: {135, 400}, scale: 1.5),
      button_spec("<", theme: :warning, id: :backspace, t: {134, 640}, radius: 8, width: 105),
      button_spec("Update Pin",
        theme: :success,
        id: {:update_pin, card_id},
        t: {245, 640},
        radius: 8,
        width: 105
      )
    ]

    graph =
      graph
      |> add_specs_to_graph(spec, id: :overlay, t: get_t({0, 58}))

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
      text_spec("[admin]",
        fill: :green,
        t: {fm.fm_width + fm.ascent, 30},
        hidden: card.user.role != :admin
      ),
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

  defp display_pin(%{graph: graph, args: %{pin: pin}} = state, status \\ false) do
    display = String.codepoints(pin) |> Enum.join(" ")
    %{ascent: ascent, fm_width: pin_w} = get_font_metrics(display, 80)

    x = 240 - pin_w / 2

    status_size = {pin_w + ascent + ascent, 80}

    status_opts =
      if status,
        do: [hidden: false, fill: status, t: {x - ascent, 380 - ascent}],
        else: [hidden: true]

    graph =
      graph
      |> Graph.modify(:pin, &text(&1, display, t: {x, 380}, hidden: false))
      |> Graph.modify(:pin_status, &rect(&1, status_size, status_opts))

    %{state | graph: graph}
  end

  defp handle_event({:click, :add}, state) do
    state = add_overlay(state)

    {:noreply, state, push: state.graph}
  end

  defp handle_event({:click, :backspace}, %{args: %{pin: pin} = args} = state)
       when byte_size(pin) > 0 do
    tail = String.last(pin)

    state =
      %{state | args: %{args | pin: String.replace(pin, tail, "")}}
      |> display_pin()

    {:noreply, state, push: state.graph}
  end

  defp handle_event({:click, {:card, id}}, state) do
    state = card_overlay(state, id)

    {:noreply, state, push: state.graph}
  end

  defp handle_event({:click, :close_overlay}, state) do
    state = clear_overlay(state)

    {:noreply, %{state | graph: state.graph}, push: state.graph}
  end

  defp handle_event({:click, :create_or_update}, state) do
    background =
      case Cards.create_or_update(state.args) do
        {:ok, _} -> :green
        _ -> :error
      end

    Process.send_after(self(), :load, 2000)

    graph = Graph.modify(state.graph, :overlay_background, &update_opts(&1, fill: background))

    {:noreply, %{state | args: %{}, graph: graph}, push: graph}
  end

  defp handle_event({:click, {:update_pin, card_id}}, state) do
    card = Enum.find(state.cards, &(&1.id == card_id))

    color =
      case Users.update(card.user, %{encrypted_pin: state.args.pin}) do
        {:ok, _user} -> :green
        _ -> :red
      end

    state = display_pin(state, color)

    Process.send_after(self(), :clear_pin, 2_000)

    {:noreply, state, push: state.graph}
  end

  defp handle_event({:value_changed, :user, id}, state) do
    {:noreply, %{state | args: Map.put(state.args, :user_id, id)}}
  end

  defp handle_event({:click, e}, state) when e in [:page_forward, :page_back] do
    step = if e == :page_forward, do: 1, else: -1
    next = state.page + step

    state =
      %{state | page: next}
      |> build_card_list()

    {:noreply, state, push: state.graph}
  end

  defp handle_event({:keypad, key}, state) when key not in [:asterisk, :pound] do
    pin = Map.get(state.args, :pin, "") <> to_string(key)

    state =
      %{state | args: Map.put(state.args, :pin, pin)}
      |> display_pin()

    {:noreply, state, push: state.graph}
  end

  defp handle_event(_, state) do
    {:noreply, state}
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
