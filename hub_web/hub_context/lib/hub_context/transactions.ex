defmodule HubContext.Transactions do
  import Ecto.Query

  alias HubContext.Schema.Transaction
  alias HubContext.Repo

  defdelegate changeset(attrs), to: Transaction

  def create(attrs) do
    changeset(attrs)
    |> Repo.insert()
  end
end
