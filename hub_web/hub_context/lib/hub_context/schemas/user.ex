defmodule HubContext.Schema.User do
  use HubContext, :schema

  defenum(FrameLocation, top_left: 1, top_mid_left: 2, top_mid_right: 3, top_right: 4, bottom_left: 5, bottom_mid: 6, bottom_right: 7)
  defenum(Role, :user_role, [:admin, :user])

  schema "users" do
    has_one(:card, HubContext.Schema.Card)
    has_many(:orders, HubContext.Schema.Order)
    has_many(:selections, HubContext.Schema.Selection)
    has_many(:transactions, through: [:orders, :transaction])

    field :card_number, :string
    field(:color, {:array, :integer}, default: [Enum.random(0..255),Enum.random(0..255),Enum.random(0..255)])
    field(:email, :string)
    field :encrypted_pin, :string
    field(:eligible_selection_types, {:array, HubContext.Schema.Selection.Type})
    field(:facebook_id, :string)
    field(:first_name, :string)
    field(:frame_location, FrameLocation)
    field(:image, :string)
    field(:last_name, :string)
    field(:nickname, :string)
    field :role, Role, default: :user

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    attrs = format_names(user, attrs)

    user
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:email, :first_name])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:facebook_id)
  end

  defp format_names(%{first_name: nil}, %{name: name} = attrs) when is_bitstring(name) do
    [first_name, last_name] = String.split(name, " ") |> parse_name()
    Map.merge(attrs, %{first_name: first_name, last_name: last_name})
  end
  defp format_names(_user, attrs), do: attrs

  defp parse_name([first, _middle, last]), do: [first, last]
  defp parse_name([first, last]), do: [first, last]
  defp parse_name([first, maybe_last | _]), do: [first, maybe_last]
end
