defmodule HubContext.Repo.Migrations.AddTransactionFields do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :merchant_guid, :string
      add :original_description, :string
    end

    create unique_index(:transactions, :guid)
  end
end
