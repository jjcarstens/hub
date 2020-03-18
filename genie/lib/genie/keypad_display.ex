defmodule Genie.KeypadDisplay do
  use GenServer

  alias OLED.Display.Server

  import Chisel.Renderer, only: [draw_text: 5]

  @defaults [
    width: 128,
    height: 32,
    driver: :ssd1306,
    type: :i2c,
    address: 0x3C,
    device: "i2c-1"
  ]

  @server __MODULE__.Server

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name:  __MODULE__)
  end

  @impl true
  def init(_opts) do
    with {:ok, server} <- Server.start_link(@defaults, name: @server),
         font_path <- Path.join(:code.priv_dir(:genie), "profont29.bdf"),
         {:ok, font} <- Chisel.Font.load(font_path)
    do
      {:ok, %{server: server, font: font}}
  else
      {:error, err} -> {:stop, err}
    end
  end

  def clear(pixel_state \\ :off) do
    if alive?() do
      Server.clear(@server, pixel_state)
      display()
    else
      :ok
    end
  end

  defdelegate display(server \\ @server), to: Server

  def put_pixel(x, y, opts \\ []), do: Server.put_pixel(@server, x, y, opts)

  def show_input(input) do
    if alive?() do
      GenServer.call(__MODULE__, {:show_input, input})
    else
      # no-op
      :ok
    end
  end

  @impl true
  def handle_call({:show_input, input},_from, state) do
    draw_text(input, 0, 0, state.font, &put_pixel/2)

    {:reply, display(), state}
  end

  defp alive?() do
    GenServer.whereis(__MODULE__) && GenServer.whereis(@server)
  end
end
