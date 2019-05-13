defmodule HubContext.Selections do
  alias HubContext.{Repo, Schema.Selection, Users}

  def record_selection!(user, type) do
    Selection.changeset(%{user_id: user.id, type: type})
    |> Repo.insert!()
  end

  def select_next_for_type(type) do
    Users.eligible_for_type(type)
    |> Enum.group_by(&length(&1.selections))
    |> Enum.sort
    |> case do
      [{_n, users} | _rem] ->
        user = Enum.random(users)
        record_selection!(user, type)
        user
      [] -> nil
    end
  end
end
