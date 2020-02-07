defmodule HubContext.Repo.Migrations.MoarOrderFields do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :price, :float
    end
  end
end
