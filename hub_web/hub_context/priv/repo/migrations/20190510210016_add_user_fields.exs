defmodule HubContext.Repo.Migrations.AddUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :color, {:array, :integer}
      add :frame_location, :integer
    end
  end
end
