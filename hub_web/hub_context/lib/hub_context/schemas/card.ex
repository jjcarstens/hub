defmodule HubContext.Schema.Card do
  use HubContext, :schema

  alias HubContext.Schema.User

  schema "cards" do
    belongs_to(:user, User)

    field :atr
    field :magstripe
    field :rfc
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:user_id, :magstripe])
    |> unique_constraint(:magstripe, name: :cards_magstripe_index)
  end
end
