defmodule HubContext.Cards do

  alias HubContext.Schema.Card
  alias HubContext.Repo

  defdelegate all(schema \\ Card), to: Repo

  def create(attrs) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert
  end

  def create_or_update(attrs) do
    case create(attrs) do
      {:ok, _} = r -> r
      {:error, %{changes: data, errors: [{field, {_, [{:constraint, :unique}, _]}}]}} ->
        Repo.get_by(Card, [{field, Map.get(data, field)}])
        |> update(attrs)
      err -> err
    end
  end

  def from_magstripe(magstripe) do
    Repo.get_by(Card, magstripe: magstripe)
  end

  def update(%Card{} = card, attrs) do
    Card.changeset(card, attrs)
    |> Repo.update()
  end
end
