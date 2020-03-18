defmodule Atm.Scene.Dashboard do
  use Atm.Scene

  alias HubContext.{Repo, Users}

  @kids ["Kaden", "Gavin", "Charlotte", "Garrett"]

  @graph Graph.build()
         |> rect({480, 800}, id: :background)

  @impl true
  def init(user, _opts) do
    graph = loader(@graph, t: center())
    user = user || Atm.Session.current_user()

    send(self(), :load)

    {:ok, %{graph: graph, user: user}, push: graph}
  end

  @impl true
  def filter_event({:click, :cards}, _, state) do
    Atm.Session.tick()

    ViewPort.set_root(:main_viewport, {Atm.Scene.Cards, nil})

    {:halt, state}
  end

  def filter_event({:click, {:kid, id}}, _, state) do
    Atm.Session.tick()

    kid = Users.get_by_id(id) |> Repo.preload(:orders)

    graph = graph_for_role(kid)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def filter_event({:click, :info}, _, state) do
    Atm.Session.tick()

    ViewPort.set_root(:main_viewport, {Atm.Scene.Info, nil})

    {:halt, state}
  end

  def filter_event(_, _, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  @impl true
  def handle_info(:load, state) do
    graph = graph_for_role(state.user)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp build_kid_preview({kid, i}) do
    order_status =
      Enum.group_by(kid.orders, & &1.status)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {{status, o}, i} ->
        x = if rem(i, 2) == 0, do: 60, else: 135
        y = if i < 2, do: 40, else: 80
        label = String.first("#{status}")

        text_spec("#{label}: #{length(o)}",
          t: {x, y},
          fill: color_for_status(status),
          hidden: length(o) == 0
        )
      end)

    {available, balance} = Users.balances(kid)

    preview = [
      button_spec("", height: 117.5, width: 440, theme: :dark, id: {:kid, kid.id}),
      text_spec(kid.first_name, font_size: 35, t: {15, 30}),
      text_spec("Balance: $", t: {15, 70}),
      text_spec("#{balance}", t: {112, 70}, fill: color_for_amount(balance)),
      text_spec("Available: $", t: {15, 100}),
      text_spec("#{available}", t: {122, 100}, fill: color_for_amount(available)),
      group_spec(order_status, t: {190, 10})
    ]

    y = 250 + i * 137.5
    group_spec(preview, t: get_t({20, y}))
  end

  defp color_for_status(status) do
    case status do
      :created -> :blue
      :requested -> :gray
      :approved -> :green
      :denied -> :red
      _ -> :yellow
    end
  end

  defp graph_for_role(%{role: :admin}) do
    kid_previews =
      Enum.map(@kids, &Users.by_email(&1 <> "@jjcarstens.com"))
      |> Enum.map(&Repo.preload(&1, :orders))
      |> Enum.with_index()
      |> Enum.map(&build_kid_preview/1)

    %{fm_width: card_w} = get_font_metrics("Cards", 60)

    @graph
    |> button("Info", height: 95, width: 210, theme: :dark, id: :info, t: get_t({20, 20}))
    |> button("Transactions",
      height: 95,
      width: 210,
      theme: :dark,
      id: :transactions,
      t: get_t({20, 135})
    )
    |> button("", height: 210, width: 210, theme: :dark, id: :cards, t: get_t({250, 20}))
    |> text("Cards", font_size: 60, t: get_t({105 - card_w / 2 + 250, 125}))
    |> add_specs_to_graph(kid_previews)
  end

  defp graph_for_role(user) do
    @graph
    |> Atm.Component.OrdersList.add_to_graph({user, user.orders})
    |> Atm.Component.Nav.add_to_graph(%{title: user.first_name})
  end
end
