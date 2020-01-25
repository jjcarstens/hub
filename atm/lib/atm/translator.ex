defmodule Atm.Translator do
  @target Application.get_env(:atm, :target)

  def center() do
    if @target == :host do
      {240, 400}
    else
      {400, 240}
    end
  end

  def center(:x), do: elem(center(), 0)
  def center(:y), do: elem(center(), 1)

  def get_t(translation) do
    get_t(@target, translation)
  end

  defp get_t(:host, translation), do: translation

  defp get_t(_rpi, {width, height}) do
    # RPI screen is 800 x 480 even though it has been
    # rotated. So we need to work off center to match
    x_offset = width - 240
    y_offset = height - 400

    {400 + x_offset, 240 + y_offset}
  end
end
