defmodule Atm.Scene do
  defmacro __using__(_opts) do
    quote do
      use Scenic.Scene

      import Scenic.{Components, Primitives}
      import Atm.Translator
      import Atm.Helpers

      alias Scenic.{Graph, ViewPort}
      alias Atm.Component.{Loader, Nav}
    end
  end
end
