defmodule TodoMvcWeb.TodoLive.ListComponent do
  use TodoMvcWeb, :live_component
  # Constants is where @todo_topic is defined
  use Constants

  alias TodoMvc.Todos

  def handle_event("toggle_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{status: !todo.status})

    socket = socket |> assign(todos: Todos.list_todos())
    TodoMvcWeb.Endpoint.broadcast(@todos_topic, "todos_updated", socket.assigns)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)

    Todos.delete_todo(todo)
    socket = assign(socket, todos: Todos.list_todos())
    TodoMvcWeb.Endpoint.broadcast(@todos_topic, "todos_updated", socket.assigns)
    {:noreply, socket}
  end
end
