defmodule HubContext.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :magstripe, :string
      add :atr, :string
      add :rfc, :string
      add :user_id, references(:users)
    end

    create(unique_index(:cards, :magstripe))
  end
end
