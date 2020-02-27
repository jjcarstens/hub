defmodule HubContext.Transactions do
  import Ecto.Query, except: [update: 2]

  alias HubContext.{Repo, Schema.Order, Schema.Transaction}

  @user_guid "USR-ef19ef9a-f241-4949-9bd0-f107f132e9f9"
  @account_guid "ACT-5f90d299-c7b4-4737-b093-601ae0c1c056"

  defdelegate changeset(attrs), to: Transaction
  defdelegate changeset(tran, attrs), to: Transaction

  def create(attrs) do
    changeset(attrs)
    |> Repo.insert()
  end

  def create_or_update(attrs) do
    guid = attrs["guid"] || attrs[:guid]

    case find_by_guid(guid) do
      nil -> create(attrs)
      t -> update(t, attrs)
    end
  end

  def find_by_guid("TRN-" <> _rest = guid) do
    Repo.get_by(Transaction, guid: guid)
  end
  def find_by_guid(_), do: nil

  def potentials_for_order(%Order{inserted_at: o_date, price: price}) do
    tax = price * 0.08
    low_price = Float.round(price - tax, 2)
    high_price = Float.round(price + tax, 2)

    low_date = NaiveDateTime.add(o_date, -86400) # -1 day
    high_date = NaiveDateTime.add(o_date, 345600) # 4 days

    from(
      t in Transaction,
      where: is_nil(t.order_id),
      where: [type: "DEBIT"],
      where: (fragment("? BETWEEN ? AND ?", t.amount, ^low_price, ^high_price) and fragment("? BETWEEN ? AND ?", t.transacted_at, ^low_date, ^high_date))
    )
    |> Repo.all()
  end

  def refresh(acc \\ [], opts \\ []) do
    opts = Keyword.put_new_lazy(opts, :from_date, &most_recent_date/0)

    case request_transactions(opts) do
      {:ok, %{"pagination" => p, "transactions" => trans}} ->
        acc =
          Enum.reduce(trans, acc, fn t, acc ->
            case create_or_update(t) do
              {:ok, t} -> [t | acc]
              _ -> acc
            end
          end)

        if p["current_page"] != p["total_pages"] do
          refresh(acc, Keyword.put(opts, :page, p["current_page"] + 1))
        else
          acc
        end

      err ->
        err
    end
  end

  def update(%Transaction{} = tran, attrs) do
    changeset(tran, attrs)
    |> Repo.update()
  end

  defp most_recent_date() do
    from(t in Transaction,
    where: not is_nil(t.guid),
    order_by: [desc_nulls_last: :date],
    select: t.date,
    limit: 1)
    |> Repo.one
  end

  defp request_transactions(opts) do
    Atrium.Accounts.list_account_transactions(@user_guid, @account_guid, opts)
  end
end
