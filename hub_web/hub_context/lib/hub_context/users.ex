defmodule HubContext.Users do
  import Ecto.Query

  alias HubContext.Schema.{Order, Selection, User}
  alias HubContext.Repo

  def by_email(nil), do: nil
  def by_email(""), do: nil
  def by_email(email), do: Repo.get_by(User, email: email)

  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert
  end

  def create_order(%User{id: user_id}, attrs) do
    Map.put(attrs, "user_id", user_id)
    |> Order.changeset()
    |> Repo.insert()
  end

  def eligible_for_type(type) do
    selections = from(s in Selection, where: s.type == ^type, where: s.inserted_at >= ^Timex.shift(DateTime.utc_now(), days: -7))

    from(
      u in User,
      where: ^type in u.eligible_selection_types,
      preload: [selections: ^selections]
    ) |> Repo.all()
  end

  def find_or_create_by_email(%{email: email} = attrs) do
    case by_email(email) do
      nil -> create(attrs)
      user -> {:ok, user}
    end
  end

  def get_by_id(user_id), do: Repo.get(User, user_id)

  def update(%User{} = user, attrs) do
    User.changeset(user, attrs)
    |> Repo.update
  end
end
