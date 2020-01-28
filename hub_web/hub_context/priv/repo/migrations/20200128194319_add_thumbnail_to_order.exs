defmodule HubContext.Repo.Migrations.AddThumbnailToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :thumbnail_url, :string
    end
  end
end
