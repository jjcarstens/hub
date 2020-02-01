defmodule Atm.Scene.Dashboard do
  use Atm.Scene

  alias HubContext.Schema.Order

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
  #  |> button("created", theme: :primary, id: :back, t: {52.5, 60}, radius: 8, width: 90)
  #  |> button("requested", theme: :secondary, id: :back, t: {147.5, 60}, radius: 8, width: 90)
  #  |> button("approved", theme: :success, id: :back, t: {242.5, 60}, radius: 8, width: 90)
  #  |> button("denied", theme: :danger, id: :back, t: {337.5, 60}, radius: 8, width: 90)
  #  |> rect({440, 645}, t: {20, 100}, fill: :blue, id: :orders)
  #  |> button("<", theme: :primary, id: :back, t: {172.5, 755}, radius: 8, width: 65)
  #  |> button(">", theme: :primary, id: :forward, t: {242.5, 755}, radius: 8, width: 65)

  def init(_args, _opts) do
    user = Atm.Session.current_user()
    name_x = 240 - byte_size(user.first_name) * 8.5

    graph =
      @graph
      |> text(user.first_name, font_size: 40, t: get_t({name_x, 40}))
      |> Atm.Component.OrdersList.add_to_graph({user, user.orders})

    {:ok, %{graph: graph, user: user}, push: graph}
  end

  def handle_input(_input, state) do
    Atm.Session.tick()
    {:noreply, state}
  end

  defp scene_for_role(graph, user) do
    pages =
      Enum.sort_by(user.orders, & &1.status)
      |> Enum.chunk_every(10)
      |> Enum.with_index(1)
      |> Enum.into(%{}, fn {v, k} -> {k, v} end)

    # display the orders
    # if user, tap thumbnail/text opens webpage
    # if admin, prompts for approval
    # status - thumbnail - title text - delete

    {:ok, %{graph: graph, user: user, pages: pages, page: 1}, push: graph}
  end
end
