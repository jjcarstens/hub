defmodule Atm.Scene.OrderSplash do
  use Atm.Scene

  alias Atm.Thumbnails
  alias HubContext.{Repo, Schema.Order}

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
         |> text("Swipe to request order",
           font_size: 40,
           t: get_t({75, 580}),
           id: :message
         )
         |> rrect({200, 200, 5}, fill: :green, id: :image, t: get_t({140, 250}))

  @impl true
  def init(%Order{} = order, _opts) do
    order = Repo.preload(order, [:user, :card])

    Phoenix.PubSub.subscribe(LAN, "magstripe")

    send(self(), :create_thumbnail)

    price = "$ #{order.price}"
    %{fm_width: price_w} = get_font_metrics(price, 60)

    graph =
      @graph
      |> text(price, font_size: 60, t: get_t({240 - price_w / 2, 200}))
      |> Atm.Component.Nav.add_to_graph(%{title: order.user.first_name})

    {:ok, %{order: order, card: order.card, graph: graph}, push: graph}
  end

  @impl true
  def handle_info(:create_thumbnail, state) do
    hash = Thumbnails.fetch_for(state.order)

    graph =
      state.graph
      |> Graph.modify(:image, &update_opts(&1, fill: {:image, hash}))

    {:noreply, state, push: graph}
  rescue
    _e ->
      {:noreply, state}
  end

  def handle_info({:magstripe, data}, %{card: %{magstripe: data}} = state) do
    Atm.Session.tick()
    Atm.Session.set_user(state.order.user)

    args =
      Map.put(state, :redirect, {Atm.Scene.Dashboard, nil})
      |> Map.delete(:graph)

    Scenic.ViewPort.set_root(:main_viewport, {Atm.Scene.SecureKeypad, args})

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    # ignore messages we don't want
    {:noreply, state}
  end

  @impl true
  def handle_input(_input, _context, state) do
    Atm.Session.tick()

    {:noreply, state}
  end
end
