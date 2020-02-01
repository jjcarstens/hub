defmodule Atm.Component.OrdersList do
  use Scenic.Component

  import Scenic.{Components, Primitives}

  alias Atm.Thumbnails
  alias HubContext.Schema.{User, Order}
  alias Scenic.Graph

  @impl true
  def verify({%User{}, orders} = data) when is_list(orders), do: {:ok, data}
  def verify(_), do: :invalid_data

  def init({user, orders}, _opts) do
    pages =
      Enum.sort_by(user.orders, & &1.status)
      |> paginate()

    graph =
      Graph.build()
      |> rect({480, 800}, id: :background)
      |> button("created",
        theme: :primary,
        id: {:sort, :created},
        t: {52.5, 60},
        radius: 8,
        width: 90
      )
      |> button("requested",
        theme: :secondary,
        id: {:sort, :requested},
        t: {147.5, 60},
        radius: 8,
        width: 90
      )
      |> button("approved",
        theme: :success,
        id: {:sort, :approved},
        t: {242.5, 60},
        radius: 8,
        width: 90
      )
      |> button("denied",
        theme: :danger,
        id: {:sort, :denied},
        t: {337.5, 60},
        radius: 8,
        width: 90
      )
      |> add_specs_to_graph(orders_list_specs(pages[1]), t: {20, 110}, id: :orders)
      |> button("<", theme: :primary, id: :back, t: {172.5, 755}, radius: 8, width: 65)
      |> button(">", theme: :primary, id: :forward, t: {242.5, 755}, radius: 8, width: 65)

    {:ok, %{graph: graph, user: user, page: 1, pages: pages}, push: graph}
  end

  defp orders_list_specs(orders) do
    Enum.with_index(orders)
    |> Enum.map(fn {order, i} ->
      group_spec(
        [
          rect_spec({200, 200},
            t: {-75, -70},
            fill: {:image, Thumbnails.fetch_for(order)},
            scale: 0.3
          ),
          text_spec(order.title, t: {65, 20}),
          button_spec("#{order.status}", theme: theme_for(order), radius: 15, t: {65, 25})
        ],
        t: {0, i * 80},
        id: {:order, order.id}
      )
    end)
  end

  defp paginate(orders) do
    orders
    |> Enum.chunk_every(10)
    |> Enum.with_index(1)
    |> Enum.into(%{}, fn {v, k} -> {k, v} end)
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
end
