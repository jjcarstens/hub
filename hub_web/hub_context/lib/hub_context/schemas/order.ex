defmodule HubContext.Schema.Order do
  use HubContext, :schema

  alias HubContext.Schema.{Transaction, User}

  @amazon_link "https://www.amazon.com/dp/"

  defenum Status, :order_status, [:created, :requested, :approved, :denied]

  schema "orders" do
    belongs_to(:user, User)
    has_one(:transaction, Transaction)
    has_one(:card, through: [:user, :card])

    field :asin, :string
    field :link, :string
    field :price, :float
    field :status, Status, default: :created
    field :thumbnail_url, :string
    field :title, :string

    timestamps()
  end

  def asin(%{link: @amazon_link <> asin}), do: asin

  def asin(link) do
    Regex.run(~r/\/dp\/(\w*)(\/|\?|$)/, link, capture: :all_but_first)
    |> hd()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%__MODULE__{} = order, attrs) do
    order
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:user_id])
    |> validate_format(:link, ~r/^http/i)
    |> update_change(:link, &normalize_link/1)
    |> update_change(:title, &String.trim/1)
    |> add_asin()
    |> unique_constraint(:asin, name: :orders_asin_user_id_index)
  end

  defp add_asin(changeset) do
    case get_field(changeset, :asin) do
      nil ->
        put_change(changeset, :asin, asin(get_field(changeset, :link)))

      _ ->
        changeset
    end
  end

  defp normalize_link(link) do
    @amazon_link <> asin(link)
  end
end
