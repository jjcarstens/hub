defmodule Hub.Schema.User do
  use Hub, :schema

  schema "users" do
    field(:email, :string)
    field(:facebook_id, :string)
    field(:first_name, :string)
    field(:image, :string)
    field(:last_name, :string)
    field(:nickname, :string)

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
    [first_name, last_name, _] = String.split(name, " ")
    Map.merge(attrs, %{first_name: first_name, last_name: last_name})
  end
  defp format_names(user, _attrs), do: user
end
