defmodule Genie.Configurator do
  @behaviour NervesHubLink.Configurator

  alias NervesHubLink.Certificate

  @impl true
  def build(config) do
    ssl =
      config.ssl
      |> add_cert()
      |> add_key()
      |> Keyword.put(:cacerts, Certificate.ca_certs())

    %{config | ssl: ssl}
  end

  defp add_cert(ssl) do
    cert =
      Application.get_env(:genie, :cert_pem)
      |> Certificate.pem_to_der()

    Keyword.put(ssl, :cert, cert)
  end

  defp add_key(ssl) do
    key =
      Application.get_env(:genie, :key_pem)
      |> Certificate.key_pem_to_der()

    Keyword.put(ssl, :key, {:ECPrivateKey, key})
  end
end
