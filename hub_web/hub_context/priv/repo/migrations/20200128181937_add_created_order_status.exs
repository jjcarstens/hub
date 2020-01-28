defmodule HubContext.Repo.Migrations.AddCreatedOrderStatus do
  use Ecto.Migration
  @disable_ddl_transaction true

  alias HubContext.Schema.Order.Status

  def up do
    execute("ALTER TYPE #{Status.type()} ADD VALUE IF NOT EXISTS 'created'")
  end

  def down do
  end
end
