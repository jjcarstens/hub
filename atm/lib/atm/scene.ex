defmodule Atm.Scene do
  defmacro __using__(_opts) do
    quote do
      use Scenic.Scene

      import Scenic.{Components, Primitives}
      import Atm.Translator

      alias Scenic.{Graph, ViewPort}
    end
  end
end
