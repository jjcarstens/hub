defmodule HubContext.Orders do
  alias HubContext.{Repo, Schema.Order, Schema.User}

  defdelegate asin(order_or_link), to: Order

  def find_by_link(%{"link" => link}) do
    Repo.get_by(Order, asin: asin(link))
  end

  def find(id), do: Repo.get(Order, id)

  def update(%Order{} = order, attrs) do
    Order.changeset(order, attrs)
    |> Repo.update
  end
end
