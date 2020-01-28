defmodule Atm.Scene.Dashboard do
  use Atm.Scene

  @graph Graph.build()
         |> text("Welcome!", t: get_t({100, 300}), font_size: 40)

  def init(_args, _opts) do
    user = Atm.Session.current_user()

    {:ok, %{user: user}, push: @graph}
  end
end
