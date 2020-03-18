defmodule Atm.Scene.Transactions do
  use Atm.Scene

  @graph Graph.build()
         |> rect({480, 800}, id: :background)

  def init(user, _opts) do
    graph = loader(@graph, t: center())
    user = user || Atm.Session.current_user()

    {:ok, %{user: user}, push: graph}
  end
end
