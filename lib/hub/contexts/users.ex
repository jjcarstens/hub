defmodule Hub.Context.Users do
  import Ecto.Query

  alias Hub.Schema.User
  alias Hub.Repo

  def by_email(nil), do: nil
  def by_email(""), do: nil
  def by_email(email), do: Repo.get_by(User, email: email)

  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert
  end

  def find_or_create_by_email(%{email: email} = attrs) do
    case by_email(email) do
      nil -> create(attrs)
      user -> {:ok, user}
    end
  end
end
