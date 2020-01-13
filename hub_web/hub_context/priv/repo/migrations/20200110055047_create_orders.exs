defmodule HubContext.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  alias HubContext.Schema.Order.Status

  def up do
    Status.create_type()

    create table(:orders) do
      add :link, :string
      add :status, Status.type()
      add :user_id, references(:users), null: false

      timestamps()
    end
  end

  def down do
    execute("DROP TYPE #{Status.type()} CASCADE")
  end
end
