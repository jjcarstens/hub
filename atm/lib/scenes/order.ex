defmodule Atm.Scene.Order do
  use Atm.Scene

  alias Atm.Thumbnails
  alias HubContext.{Orders, Repo}

  # @status_buttons [

  # ]

  @impl true
  def init([order_id, redirect], _opts) do
    order = Orders.find(order_id) |> Repo.preload(:user)
    user = Atm.Session.current_user()

    redirect = redirect || {Atm.Scene.Dashboard, nil}

    status_buttons = [
      button_spec("created",
        theme: :primary,
        id: {:change, :created},
        t: {52.5, 60},
        radius: 8,
        width: 90
      ),
      button_spec("requested",
        theme: :secondary,
        id: {:change, :requested},
        t: {147.5, 60},
        radius: 8,
        width: 90
      ),
      button_spec("approved",
        theme: :success,
        id: {:change, :approved},
        t: {242.5, 60},
        radius: 8,
        width: 90
      ),
      button_spec("denied",
        theme: :danger,
        id: {:change, :denied},
        t: {337.5, 60},
        radius: 8,
        width: 90
      )
    ]

    fm = Scenic.Cache.Static.FontMetrics.get!(:roboto)

    title = FontMetrics.wrap(order.title, 380, 20, fm)

    graph =
      Graph.build()
      |> rect({480, 800}, id: :background, fill: color_for_status(order), t: get_t({0, 0}))
      |> text(title, t: get_t({10, 200}))
      |> text("$ #{order.price}", font_size: 40, t: get_t({180, 310}))
      |> rect({200, 200}, fill: {:image, Thumbnails.fetch_for(order)}, t: get_t({140, 350}))
      |> text("#{order.status}: #{order.updated_at}", t: get_t({80, 600}))
      |> button("Open",
        theme: :warning,
        id: :open,
        t: get_t({135, 650}),
        scale: 1.5,
        width: 70,
        radius: 10
      )
      |> button("Delete",
        theme: :danger,
        id: :delete,
        t: get_t({250, 650}),
        scale: 1.5,
        width: 70,
        radius: 10
      )
      |> add_specs_to_graph(status_buttons, hidden: user.role != :admin, t: get_t({0, 50}))
      |> Atm.Component.Nav.add_to_graph(%{redirect: redirect})

    {:ok, %{graph: graph, order: order, redirect: redirect}, push: graph}
  end

  @impl true
  def filter_event({:click, :open}, _, state) do
    Atm.Session.tick()

    first_name = Repo.preload(state.order, :user).user.first_name

    Phoenix.PubSub.broadcast_from!(
      LAN,
      self(),
      "orders:#{first_name}:open",
      {:open, state.order.link}
    )

    {:noreply, state}
  end

  def filter_event({:click, :delete}, _, state) do
    specs = [
      rect_spec({200, 100}, fill: :black),
      triangle_spec({{100, 150}, {50, 100}, {150, 100}}, fill: :black),
      text_spec("Are you sure?", t: {40, 25}),
      button_spec("Cancel",
        id: {:confirm_delete, :cancel},
        theme: :secondary,
        radius: 3,
        t: {10, 50}
      ),
      button_spec("Ok", id: {:confirm_delete, :ok}, width: 80, radius: 3, t: {110, 50})
    ]

    graph =
      state.graph
      |> add_specs_to_graph(specs, t: get_t({200, 498}), id: :confirm_overlay)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def filter_event({:click, {:change, status}}, _, state) do
    Atm.Session.tick()
    state = update_order_status(state, status)

    {:noreply, state, push: state.graph}
  end

  def filter_event({:click, {:confirm_delete, :cancel}}, _, state) do
    graph = Graph.delete(state.graph, :confirm_overlay)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def filter_event({:click, {:confirm_delete, :ok}}, _, state) do
    Repo.delete(state.order)
    ViewPort.set_root(:main_viewport, state.redirect)

    {:noreply, state}
  end

  @impl true
  def handle_input(
        {:cursor_button, {:left, :press, _, _}},
        _,
        %{order: %{status: :created}} = state
      ) do
    args = %{
      order: state.order,
      title: "Complete Order Request",
      redirect: {__MODULE__, [state.order.id, state.redirect]}
    }

    ViewPort.set_root(:main_viewport, {Atm.Scene.SecureKeypad, args})

    {:noreply, state}
  end

  def handle_input(e, _, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  defp color_for_status(%{status: status}) do
    case status do
      :created -> :blue
      :requested -> :gray
      :approved -> :green
      :denied -> :red
      _ -> :yellow
    end
  end

  def update_order_status(%{order: order} = state, status) do
    case Orders.update(order, %{status: status}) do
      {:ok, order} ->
        graph =
          state.graph
          |> Graph.modify(:background, &update_opts(&1, fill: color_for_status(order)))

        %{state | graph: graph, order: order}

      # TODO: do somethign with error here
      {:error, _} ->
        state
    end
  end
end
