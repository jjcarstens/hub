defmodule HubContext.Schema.Selection do
  use HubContext, :schema

  alias HubContext.Schema.User

  defenum(Type, :type, [:dishwasher, :family, :meal, :misc, :truck])

  schema "selections" do
    belongs_to(:user, User)
    field(:type, Type)

    timestamps(updated_at: false)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%__MODULE__{} = selection, attrs) do
    selection
    |> cast(attrs, [:type, :user_id])
    |> validate_required([:type, :user_id])
  end
end
