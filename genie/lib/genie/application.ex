defmodule Genie.Application do
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Genie.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  def children(target) do
    cert = Application.get_env(:genie, :certfile)
           |> NervesHub.Certificate.pem_to_der

    key = Application.get_env(:genie, :keyfile)
          |> X509.PrivateKey.from_pem!
          |> X509.PrivateKey.to_der()

    [
      {NervesHub.Supervisor, [cert: cert, key: {:ECPrivateKey, key}]},
      {Genie.Websocket, []}
    ] ++ target_children(target)
  end

  # List all child processes to be supervised
  defp target_children(:host), do: []

  defp target_children(_target) do
    [
      {Genie.MotionSensor, []},
      {Genie.StorageRelay, []},
      %{id: Genie.Keypad, start: {Genie.Keypad, :start_link, []}},
    ]
  end
end
