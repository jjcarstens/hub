defmodule HubContext.Repo.Migrations.AddSelectionsTable do
  use Ecto.Migration

  alias HubContext.Schema.Selection.Type

  def change do
    Type.create_type()

    create table(:selections) do
      add :user_id, references(:users), null: false
      add :type, Type.type(), null: false

      timestamps(updated_at: false)
    end
  end
end
