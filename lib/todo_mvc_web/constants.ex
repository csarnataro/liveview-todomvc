defmodule Constants do
  defmacro __using__(_) do
    quote do
      @todos_topic "todos_topic"
    end
  end
end
