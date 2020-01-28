defmodule Atm.Scene.OrderSplash do
  use Atm.Scene

  alias HubContext.{Repo, Schema.Order}

  @graph Graph.build()
         |> rect({480, 800}, id: :background)
         |> text("User",
           font_size: 40,
           t: get_t({160, 80}),
           id: :user
         )
         |> text("Swipe to complete",
           font_size: 40,
           t: get_t({100, 580}),
           id: :message
         )
         |> rrect({200, 200, 5}, fill: :green, id: :image, t: get_t({140, 200}))

  @impl true
  def init(%Order{} = order, _opts) do
    order = Repo.preload(order, [:user, :card])

    # Scenic.Sensor.subscribe(:magstripe)
    Phoenix.PubSub.subscribe(LAN, "magstripe")

    send(self(), :create_thumbnail)

    graph =
      @graph
      |> Graph.modify(:user, &text(&1, order.user.first_name))

    {:ok, %{order: order, card: order.card, graph: graph}, push: graph}
  end

  @impl true
  def handle_info(:create_thumbnail, state) do
    url = resize_thumbnail(state.order)
    name = "order-#{state.order.id}.jpg"

    path =
      Application.get_env(:atm, :thumbnail_dir, "/tmp/thumbnails")
      |> Path.join(name)

    unless File.exists?(path) do
      File.mkdir_p(Path.dirname(path))
      Download.from(url, path: path)
    end

    hash = Scenic.Cache.Support.Hash.file!(path, :sha)

    Scenic.Cache.Static.Texture.load(path, hash)

    graph =
      state.graph
      |> Graph.modify(:image, &update_opts(&1, fill: {:image, hash}))

    {:noreply, state, push: graph}
  rescue
    _e ->
      {:noreply, state}
  end

  # def handle_info({:sensor, :data, {:magstripe, %{data: data}, _}}, %{card: %{magstripe: data}} = state) do
  def handle_info({:magstripe, data}, %{card: %{magstripe: data}} = state) do
    Atm.Session.tick()

    args =
      Map.put(state, :redirect, Atm.Scene.Dashboard)
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

  defp resize_thumbnail(%{thumbnail_url: url}) do
    [size | _] = Regex.run(~r/\._.*_\.(jpg|jpeg)$/, url, capture: :first)
    new = String.replace(size, ~r/\d+/, "200")
    String.replace(url, size, new)
  end
end
