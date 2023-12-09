defmodule TodoMvcWeb.TodoLive.Index do
  alias TodoMvc.Todos
  alias TodoMvc.Todos.Todo

  require Logger
  use TodoMvcWeb, :live_view
  # Constants is where @todo_topic is defined
  use Constants

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TodoMvcWeb.Endpoint.subscribe(@todos_topic)

    todos = Todos.list_todos()

    filter_info = compute_filter_info(todos, nil)

    {:ok,
     assign(socket, :todo, %Todo{})
     |> assign(:todos, todos)
     |> assign(:total_items, length(todos))
     |> assign(:filter_info, filter_info)}
  end

  @impl true
  def handle_info(%{event: "todos_updated", payload: %{todos: todos}}, socket) do
    filter_info = compute_filter_info(todos, nil)

    {:noreply,
     socket
     |> assign(todos: todos)
     |> assign(:total_items, length(todos))
     |> assign(filter_info: filter_info)}
  end

  @impl true
  def handle_event("delete_completed", _, socket) do
    Todos.delete_all_completed()
    todos = Todos.list_todos()

    IO.inspect(socket.assigns.filter_info.filter)

    filter = socket.assigns.filter_info.filter

    status =
      case filter do
        "completed" -> true
        "active" -> false
        _ -> nil
      end

    filter =
      case filter do
        "all" -> nil
        _ -> filter
      end

    todos = Todos.list_todos()
    filter_info = compute_filter_info(todos, filter)

    filtered_items = todos |> Enum.filter(fn i -> i.status == status || status == nil end)

    {:noreply,
     socket
     |> assign(:todos, filtered_items)
     |> assign(filter_info: filter_info)
     |> assign(:total_items, length(todos))}
  end

  @impl true
  def handle_event("filter", %{"id" => filter}, socket) do
    status =
      case filter do
        "completed" -> true
        "active" -> false
        _ -> nil
      end

    filter =
      case filter do
        "all" -> nil
        _ -> filter
      end

    todos = Todos.list_todos()
    filter_info = compute_filter_info(todos, filter)

    filtered_items = todos |> Enum.filter(fn i -> i.status == status || status == nil end)

    {:noreply,
     socket
     |> assign(:todos, filtered_items)
     |> assign(filter_info: filter_info)}
  end

  defp compute_filter_info(todos, filter) do
    active_count = todos |> Enum.count(fn i -> !i.status end)
    completed_count = todos |> Enum.count(fn i -> i.status end)
    show_clear_completed = completed_count > 0
    remaining_items = length(todos) - completed_count

    %{
      filter: filter,
      active_count: active_count,
      remaining_items: remaining_items,
      highlight_toggle: active_count == length(todos),
      completed_count: completed_count,
      show_clear_completed: show_clear_completed
    }
  end
end
