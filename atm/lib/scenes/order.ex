defmodule Atm.Scene.Order do
  use Atm.Scene

  alias Atm.Thumbnails
  alias HubContext.{Orders, Repo}

  @impl true
  def init(order_id, _opts) do
    order = Orders.find(order_id)

    graph =
      Graph.build()
      |> rect({480, 800}, fill: color_for_status(order), t: get_t({0, 0}))
      |> text(order.title, t: get_t({10, 100}))
      |> text("$ #{order.price}", font_size: 40, t: get_t({180, 160}))
      |> rect({200, 200}, fill: {:image, Thumbnails.fetch_for(order)}, t: get_t({140, 200}))
      |> text("#{order.status}: #{order.updated_at}", t: get_t({80, 500}))
      |> button("Open", theme: :warning, id: :open, t: get_t({200, 600}))
      |> button("X", id: :close, radius: 4, theme: :danger, t: get_t({420, 20}))

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

    Phoenix.PubSub.broadcast_from!(LAN, self(), "orders:#{first_name}:open", {:open, state.order.link})

    {:noreply, state}
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
end
