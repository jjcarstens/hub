defmodule Atm.Scene do
  defmacro __using__(_opts) do
    quote do
      use Scenic.Scene

      import Scenic.{Components, Primitives}
      import Atm.Translator
      import Atm.Helpers
      import Scenic.Loader.Component

      alias Scenic.{Graph, ViewPort}
      alias Atm.Component.Nav
    end
  end
end
