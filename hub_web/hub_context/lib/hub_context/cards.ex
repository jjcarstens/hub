defmodule HubContext.Cards do
  import Ecto.Query

  alias HubContext.Schema.Card
  alias HubContext.Repo

  def create(attrs) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert
  end

  def from_magstripe(magstripe) do
    Repo.get_by(Card, magstripe: magstripe)
  end
end
