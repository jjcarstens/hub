defmodule HubContext.Repo.Migrations.AddEligibleSelectionTypesToUser do
  use Ecto.Migration

  alias HubContext.Schema.Selection

  def change do
    alter table(:users) do
      add(:eligible_selection_types, {:array, Selection.Type.type()})
    end
  end
end
