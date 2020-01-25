defmodule Atm.Component.Nav do
  # use Scenic.Component

  # alias Scenic.ViewPort
  # alias Scenic.Graph

  # import Scenic.Primitives
  # import Scenic.Components

  # @height 60

  # # --------------------------------------------------------
  # def verify(scene) when is_atom(scene), do: {:ok, scene}
  # def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  # def verify(_), do: :invalid_data

  # # ----------------------------------------------------------------------------
  # def init(current_scene, opts) do
  #   styles = opts[:styles] || %{}

  #   # Get the viewport width
  #   {:ok, %ViewPort.Status{size: {width, _}}} =
  #     opts[:viewport]
  #     |> ViewPort.info()

  #   graph =
  #     Graph.build(styles: styles, font_size: 20)
  #     |> rect({width, @height}, fill: {48, 48, 48})
  #     |> button("Back", translate: {14, 35}, theme: :info, id: :back_button)

  #   {:ok, %{graph: graph, viewport: opts[:viewport]}, push: graph}
  # end

  # # ----------------------------------------------------------------------------
  # def filter_event({:click, :button_id}, _, %{viewport: vp} = state) do
  #   ViewPort.set_root(vp, Atm.Scene.Splash)
  #   {:halt, state}
  # end
end
