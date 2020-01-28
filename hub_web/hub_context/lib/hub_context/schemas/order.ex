defmodule HubContext.Schema.Order do
  use HubContext, :schema

  alias HubContext.Schema.{Transaction, User}

  defenum Status, :order_status, [:created, :requested, :approved, :denied]

  schema "orders" do
    belongs_to(:user, User)
    has_one(:transaction, Transaction)
    has_one(:card, through: [:user, :card])

    field :link, :string
    field :status, Status, default: :created
    field :thumbnail_url, :string

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
    [asin | _] = Regex.run(~r/\/dp\/(.*)\//, link, capture: :all_but_first)
    "https://www.amazon.com/dp/#{asin}"
  end
end
