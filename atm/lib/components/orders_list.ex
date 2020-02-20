defmodule Atm.Component.OrdersList do
  use Scenic.Component

  import Atm.Translator
  import Atm.Helpers
  import Scenic.{Components, Primitives}

  alias Atm.Thumbnails
  alias HubContext.Schema.{Order, User}
  alias HubContext.Users
  alias Scenic.Graph

  @graph Graph.build()
         # |> rect({480, 800}, id: :background)
         |> button("created",
           theme: :primary,
           id: {:sort, :created},
           t: get_t({52.5, 190}),
           radius: 8,
           width: 90
         )
         |> button("requested",
           theme: :secondary,
           id: {:sort, :requested},
           t: get_t({147.5, 190}),
           radius: 8,
           width: 90
         )
         |> button("approved",
           theme: :success,
           id: {:sort, :approved},
           t: get_t({242.5, 190}),
           radius: 8,
           width: 90
         )
         |> button("denied",
           theme: :danger,
           id: {:sort, :denied},
           t: get_t({337.5, 190}),
           radius: 8,
           width: 90
         )
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

  @impl true
  def verify({%User{}, orders} = data) when is_list(orders), do: {:ok, data}
  def verify(_), do: :invalid_data

  @impl true
  def init({user, orders}, _opts) do
    orders = orders || []

    state =
      %{graph: @graph, orders: orders, pages: [], page: 1, sort: :all, user: user}
      |> paginate()
      |> update_orders()
      |> add_balances()

    Phoenix.PubSub.subscribe(LAN, "orders:created")

    {:ok, state, push: state.graph}
  end

  @impl true
  def handle_info(%Order{user_id: oid} = order, %{user: %{id: uid, role: role}} = state)
      when oid == uid or role == :admin do
    state =
      %{state | orders: [order | state.orders]}
      |> paginate()
      |> update_orders()

    {:noreply, state, push: state.graph}
  end

  @impl true
  def handle_input(_input, _context, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  @impl true
  def filter_event({:click, {:order, id}}, _, state) do
    Scenic.ViewPort.set_root(
      :main_viewport,
      {Atm.Scene.Order, [id, {Atm.Scene.Dashboard, state.user}]}
    )

    {:noreply, state, push: state.graph}
  end

  def filter_event({:click, {:sort, sort}}, _, state) do
    Atm.Session.tick()

    # Clicked the same sort button, so revert to all
    sort = if sort == state.sort, do: :all, else: sort

    state =
      %{state | page: 1, sort: sort}
      |> paginate()
      |> update_orders()

    {:noreply, state, push: state.graph}
  end

  def filter_event({:click, e}, _, state) when e in [:page_forward, :page_back] do
    Atm.Session.tick()

    step = if e == :page_forward, do: 1, else: -1
    next = state.page + step

    state =
      %{state | page: next}
      |> update_orders()

    {:noreply, state, push: state.graph}
  end

  def filter_event(e, _, state) do
    Atm.Session.tick()

    IO.inspect(e)

    {:noreply, state}
  end

  defp add_balances(%{graph: graph} = state) do
    text_height = 100
    val_height = text_height + 55
    {available, balance} = Users.balances(state.user)

    graph =
      graph
      |> text("Available", t: get_t({75, text_height}), font_size: 30)
      |> text("$ #{available}",
        t: get_t({30, val_height}),
        font_size: 55,
        fill: color_for_amount(available),
        text_align: :left
      )
      |> text("Balance", t: get_t({300, text_height}), font_size: 30)
      |> text("$ #{balance}",
        t: get_t({265, val_height}),
        font_size: 55,
        fill: color_for_amount(balance),
        text_align: :left
      )

    %{state | graph: graph}
  end

  defp add_navigation(graph, current_page, pages) do
    total = map_size(pages)

    graph
    |> Graph.modify(:page_back, &update_opts(&1, hidden: current_page == 1))
    |> Graph.modify(:page_forward, &update_opts(&1, hidden: current_page == total))
  end

  defp do_sort(orders, :all) do
    Enum.sort_by(orders, & &1.status)
  end

  defp do_sort(orders, status) do
    Enum.filter(orders, &(&1.status == status))
  end

  defp format_title(title) when byte_size(title) < 39, do: title

  defp format_title(title) do
    String.slice(title, 0..34) <> "..."
  end

  defp orders_list_specs(nil), do: []

  defp orders_list_specs(orders) do
    Enum.with_index(orders)
    |> Enum.map(fn {order, i} ->
      group_spec(
        [
          text_spec(format_title(order.title), t: {65, 20}),
          rect_spec({200, 200},
            t: {-75, -70},
            fill: {:image, Thumbnails.fetch_for(order)},
            scale: 0.3
          ),
          button_spec("#{order.status}",
            theme: theme_for(order),
            radius: 15,
            t: {65, 25},
            id: {:order, order.id}
          ),
          text_spec("$ #{order.price}", t: {200, 50}),
          button_spec("",
            id: {:order, order.id},
            theme: %{active: :clear, text: :white, border: :clear, background: :clear},
            height: 60,
            width: 460
          )
        ],
        t: {0, i * 80},
        id: {:order, order.id}
      )
    end)
  end

  defp paginate(%{orders: orders} = state) do
    pages =
      orders
      |> do_sort(state.sort)
      |> Enum.sort_by(& &1.inserted_at)
      |> Enum.chunk_every(6)
      |> Enum.with_index(1)
      |> Enum.into(%{}, fn {v, k} -> {k, v} end)

    %{state | pages: pages}
  end

  defp theme_for(%{status: status}) do
    case status do
      :created -> :primary
      :requested -> :secondary
      :approved -> :success
      :denied -> :danger
      _ -> :warning
    end
  end

  defp update_orders(%{graph: graph, page: page, pages: pages} = state) do
    next_orders = orders_list_specs(pages[page])

    graph =
      graph
      |> add_navigation(page, pages)
      |> Graph.delete(:orders)
      |> add_specs_to_graph(next_orders, id: :orders, t: get_t({20, 250}))

    %{state | graph: graph}
  end
end
