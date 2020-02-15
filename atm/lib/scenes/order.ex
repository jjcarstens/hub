defmodule Atm.Scene.Order do
  use Atm.Scene

  alias Atm.Thumbnails
  alias HubContext.{Orders, Repo}

  # @status_buttons [

  # ]

  @impl true
  def init([order_id, redirect], _opts) do
    order = Orders.find(order_id)
    user = Atm.Session.current_user()

    redirect = redirect || {Atm.Scene.Dashboard, nil}

    status_buttons = [
      button_spec("created",
        theme: :primary,
        id: {:change, :created},
        t: get_t({52.5, 60}),
        radius: 8,
        width: 90
      ),
      button_spec("requested",
        theme: :secondary,
        id: {:change, :requested},
        t: get_t({147.5, 60}),
        radius: 8,
        width: 90
      ),
      button_spec("approved",
        theme: :success,
        id: {:change, :approved},
        t: get_t({242.5, 60}),
        radius: 8,
        width: 90
      ),
      button_spec("denied",
        theme: :danger,
        id: {:change, :denied},
        t: get_t({337.5, 60}),
        radius: 8,
        width: 90
      )
    ]

    graph =
      Graph.build()
      |> rect({480, 800}, id: :background, fill: color_for_status(order), t: get_t({0, 0}))
      |> text(order.title, t: get_t({10, 200}))
      |> text("$ #{order.price}", font_size: 40, t: get_t({180, 280}))
      |> rect({200, 200}, fill: {:image, Thumbnails.fetch_for(order)}, t: get_t({140, 320}))
      |> text("#{order.status}: #{order.updated_at}", t: get_t({80, 600}))
      |> button("Open", theme: :warning, id: :open, t: get_t({180, 650}), scale: 1.5, radius: 10)
      |> add_specs_to_graph(status_buttons, hidden: user.role != :admin, t: get_t({0, 50}))
      |> Atm.Component.Nav.add_to_graph(%{redirect: redirect})

    {:ok, %{graph: graph, order: order}, push: graph}
  end

  @impl true
  def filter_event({:click, :close}, _, state) do
    ViewPort.set_root(:main_viewport, {Atm.Scene.Dashboard, nil})
    {:noreply, state}
  end

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

  def filter_event({:click, {:change, status}}, _, state) do
    state = update_order_status(state, status)

    {:noreply, state, push: state.graph}
  end

  @impl true
  def handle_input(_, _, state) do
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
