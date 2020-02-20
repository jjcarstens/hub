defmodule Atm.Scene.Splash do
  use Atm.Scene

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
         |> group(
           fn g ->
             circle(g, 120, fill: :blue)
             |> text("$",
               font_size: 200,
               text_align: :center,
               fill: :grey,
               font_blur: 1.0,
               translate: {3, 64}
             )
             |> text("$", font_size: 200, text_align: :center, translate: {0, 60})
           end,
           id: :logo,
           t: {center(:x), center(:y) / 1.2}
         )
         |> text("Swipe or scan your card",
           font_size: 40,
           t: get_t({60, 580}),
           hidden: true,
           id: :message
         )
         |> slider({{14, 255}, 65}, id: :brightness, t: get_t({100, 740}), hidden: true)

  @impl true
  def init(_first_scene, _opts) do
    state = %{}

    Phoenix.PubSub.subscribe(LAN, "magstripe")

    {:ok, state, push: @graph}
  end

  @impl true
  def handle_info({:magstripe, data}, state) do
    Atm.Session.wake()

    case HubContext.Cards.from_magstripe(data) do
      nil ->
        :ignore

      card ->
        HubContext.Repo.preload(card, :user)
        |> Map.get(:user)
        |> Atm.Session.set_user()

        Scenic.ViewPort.set_root(:main_viewport, {Atm.Scene.Dashboard, nil})
    end

    {:noreply, state}
  end

  @impl true
  def handle_input({:cursor_button, {_, :press, _, _}}, _context, state) do
    Atm.Session.tick()

    graph =
      @graph
      |> Graph.modify(:message, &update_opts(&1, hidden: false))
      |> Graph.modify(:brightness, &update_opts(&1, hidden: false))

    {:noreply, state, push: graph}
  end

  def handle_input(_input, _context, state) do
    Atm.Session.tick()

    {:noreply, state}
  end

  @impl true
  def filter_event({:value_changed, :brightness, val}, _from, state) do
    Atm.Session.set_brightness(val)
    {:noreply, state}
  end
end
