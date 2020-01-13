defmodule HubContext.Schema.Order do
  use HubContext, :schema

  alias HubContext.Schema.{Transaction, User}

  defenum Status, :order_status, [:requested, :approved, :denied]

  schema "orders" do
    belongs_to(:user, User)
    has_one(:transaction, Transaction)

    field :link, :string
    field :status, Status, default: :requested

    timestamps()
  end


  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%__MODULE__{} = transaction, attrs) do
    transaction
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:user_id])
    |> validate_format(:link, ~r/^http/i)
    |> update_change(:link, &normalize_link/1)
  end

  defp normalize_link(link) do
    %{URI.parse(link) | query: nil}
    |> to_string()
  end
end
