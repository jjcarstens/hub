defmodule Genie.Radio do
  @behaviour HubContext.Radio

  def fan_light() do
    file_path("fan_light.iq")
    |> Replex.replay(433907740, sample_rate: 250_000)
  end

  def fan_speed(speed) do
    case convert_fan_speed(speed) do
      x when is_integer(x) ->
        # potentially need 4.3393e8 freq
        file_path("fan_#{x}")
        |> blast_it(433907740, sample_rate: 250_000)

      err -> err
    end
  end

  def outlet_off(outlet_id) do
    file_path("outlet_#{outlet_id}_off")
    |> blast_it(3.14993e8, sample_rate: 250_000)
  end

  def outlet_on(outlet_id) do
    file_path("outlet_#{outlet_id}_on")
    |> blast_it(3.14993e8, sample_rate: 250_000)
  end

  defp blast_it(recording, freq, opts) do
    repeat = opts[:repeat] || 3
    task =
      Task.async(fn ->
        Enum.map(1..repeat, fn _ -> Replex.replay(recording, freq, opts) end)
      end)

    Task.await(task, repeat * 10_000)
  end

  defp convert_fan_speed(speed) do
    str = to_string(speed)
    cond do
      str =~ ~r/off|0/ -> 0
      str =~ ~r/low|1/ -> 1
      str =~ ~r/mid|2/ -> 2
      str =~ ~r/high|3/ -> 3
      true -> {:error, "invalid fan speed: #{speed}"}
    end
  end

  defp file_path(file_name) do
    Path.join(:code.priv_dir(:genie), file_name)
  end
end
