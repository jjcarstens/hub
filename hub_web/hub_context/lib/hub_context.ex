defmodule HubContext do
  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import EctoEnum

      alias __MODULE__
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
