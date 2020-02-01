defmodule HubContext.Repo.Migrations.AddAsinAndTitleToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :asin, :string
      add :title, :string
    end

    create unique_index(:orders, [:asin, :user_id])
  end
end
