defmodule TodoMvc.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoMvc.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        status: true,
        text: "some text"
      })
      |> TodoMvc.Todos.create_todo()

    todo
  end
end
