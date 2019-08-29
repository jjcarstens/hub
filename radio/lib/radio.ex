defmodule Radio do
  def fan_light() do
    file_path("fan_light.iq")
    |> Replex.replay(433907740, sample_rate: 250_000)
  end

  def lights_on() do
    file_path("lights_on.iq")
    |> Replex.replay(4.33907e8, sample_rate: 250_000)
  end

  def lights_off() do
    file_path("lights_off.iq")
    |> Replex.replay(4.33907e8, sample_rate: 250_000)
  end

  def lights_on2() do
    file_path("lights_on2.iq")
    |> Replex.replay(4.33907e8, sample_rate: 250_000)
  end

  def lights_off2() do
    file_path("lights_off2.iq")
    |> Replex.replay(4.33907e8, sample_rate: 250_000)
  end

  defp file_path(file_name) do
    Path.join(:code.priv_dir(:radio), file_name)
  end
end
