defmodule Center do
  @moduledoc """
  Displays a Circle and crosshairs in the center of the screen for comparing orientation
  """

  use Atm.Scene

  def init(_, _opts) do
    {center_x, center_y} = center()

    graph =
      Graph.build()
      |> circle(120, fill: :blue, t: {center_x, center_y})
      |> line({{center_x, center_y}, {center_x + 120, center_y}}, stroke: {4, :yellow})
      |> line({{center_x, center_y}, {center_x, center_y + 120}}, stroke: {4, :red})
      |> line({{center_x, center_y}, {center_x - 120, center_y}}, stroke: {4, :green})
      |> line({{center_x, center_y}, {center_x, center_y - 120}}, stroke: {4, :cyan})

    {:ok, %{}, push: graph}
  end
end
