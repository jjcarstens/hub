defmodule HubContext.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, null: false)
      add(:facebook_id, :string)
      add(:first_name, :string, null: false)
      add(:image, :string)
      add(:last_name, :string)
      add(:nickname, :string)

      timestamps()
    end

    create(unique_index(:users, :email))
    create(unique_index(:users, :facebook_id))
  end
end
