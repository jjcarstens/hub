defmodule Atm.Helpers do
  def color_for_amount(amount, default \\ :white) do
    if amount < 0, do: :red, else: default
  end

  def get_font_metrics(text, font_size, font \\ :roboto) do
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)
    %{font_size: font_size, ascent: ascent, fm_width: fm_width}
  end
end
