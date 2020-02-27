defmodule HubContext.Users do
  import Ecto.Query

  alias HubContext.Schema.{Order, Selection, Transaction, User}
  alias HubContext.Repo

  def all(), do: Repo.all(User)

  # returns {available, balance}
  def balances(%User{} = user) do
    credits = from(t in Transaction, where: [user_id: ^user.id, type: "CREDIT"], select: [:amount])
    |> Repo.all()
    |> Enum.map(& &1.amount)
    |> Enum.sum()

    debits = from(t in Transaction, where: t.user_id == ^user.id and is_nil(t.order_id) and t.type == "DEBIT", select: [:amount])
    |> Repo.all()
    |> Enum.map(& &1.amount)
    |> Enum.sum()

    balance = Float.round(credits - debits, 2)

    from(o in Order,
    where: o.user_id == ^user.id and o.status in ["requested", "approved"],
    preload: [:transaction])
    |> Repo.all
    |> Enum.reduce({balance, balance}, &increment_balance/2)
  end

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

  def get_by_id(nil), do: nil
  def get_by_id(user_id), do: Repo.get(User, user_id)

  def update(%User{} = user, attrs) do
    User.changeset(user, attrs)
    |> Repo.update
  end

  defp increment_balance(order, {available, balance}) do
    if is_nil(order.transaction) do
      amount = order.price || 0
      {Float.round(available - amount, 2), balance}
    else
      amount = order.transaction.amount || 0
      {Float.round(available - amount, 2), Float.round(balance - amount, 2)}
    end
  end
end
