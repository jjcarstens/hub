defmodule HubContext.Schema.Transaction do
  use HubContext, :schema

  alias HubContext.Schema.{Order, User}

  defenum(Status, :transaction_status, [:PENDING, :POSTED])
  defenum(Type, :transaction_type, [:CREDIT, :DEBIT])

  schema "transactions" do
    belongs_to(:user, User)
    belongs_to(:order, Order)

    field :amount, :float
    field :date, :date
    field :description, :string
    field :guid, :string
    field :posted_at, :utc_datetime
    field :status, Status
    field :transacted_at, :utc_datetime
    field(:type, Type)

    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%__MODULE__{} = transaction, attrs) do
    transaction
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:status, :type])
  end
end
