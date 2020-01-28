defmodule HubContext.Orders do
  alias HubContext.{Repo, Schema.Order, Schema.User}

  defdelegate asin(order_or_link), to: Order

  def update(%Order{} = order, attrs) do
    Order.changeset(order, attrs)
    |> Repo.update
  end
end
