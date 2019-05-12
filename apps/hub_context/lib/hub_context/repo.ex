defmodule HubContext.Repo do
  use Ecto.Repo,
    otp_app: :hub_context,
    adapter: Ecto.Adapters.Postgres
end
