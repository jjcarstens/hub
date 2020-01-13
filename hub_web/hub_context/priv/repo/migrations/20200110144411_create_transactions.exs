defmodule HubContext.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  alias HubContext.Schema.Transaction.{Status, Type}

  def up do
    Status.create_type()
    Type.create_type()

    create table(:transactions) do
      add :amount, :float
      add :date, :date
      add :description, :string
      add :guid, :string
      add :posted_at, :utc_datetime
      add :order_id, references(:orders)
      add :status, Status.type(), null: false
      add :transacted_at, :utc_datetime
      add :user_id, references(:users)
      add :type, Type.type(), null: false

      timestamps()
    end
  end

  def down do
    execute("DROP TYPE #{Status.type()} CASCADE")
    execute("DROP TYPE #{Type.type()} CASCADE")
  end
end
