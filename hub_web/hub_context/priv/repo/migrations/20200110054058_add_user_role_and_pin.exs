defmodule HubContext.Repo.Migrations.AddUserRoleAndPin do
  use Ecto.Migration

  alias HubContext.Schema.User.Role

  def up do
    Role.create_type()

    alter table(:users) do
      add :card_number, :string
      add :encrypted_pin, :string
      add :role, Role.type()
    end
  end


  def down do
    execute("DROP TYPE #{Role.type()} CASCADE")
  end
end
