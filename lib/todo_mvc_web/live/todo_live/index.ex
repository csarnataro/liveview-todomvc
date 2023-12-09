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

    filter_info = compute_filter_info(todos)

    Logger.warning(inspect(filter_info))

    {:ok,
     assign(socket, :todo, %Todo{})
     |> assign(:todos, todos)
     |> assign(:total_items, length(todos))
     |> assign(:filter_info, filter_info)}
  end

  @impl true
  def handle_info(%{event: "todos_updated", payload: %{todos: todos}}, socket) do
    filter_info = compute_filter_info(todos)

    {:noreply, socket |> assign(todos: todos) |> assign(filter_info: filter_info)}
  end

  # @impl true
  # def handle_event("toggle_all", _, socket) do
  #   Logger.warning("toggle_all")
  #   # # if at least one todo is not completed, then we want to complete all
  #   # # otherwise, we want to uncomplete all
  #   # case Todos.list_todos() |> Enum.all?(fn todo -> todo.status end) do
  #   #   true -> Todos.update_all(status: false)
  #   #   false -> Todos.update_all(status: true)
  #   # end

  #   # TodoMvcWeb.Endpoint.broadcast(@todos_topic, "todos_updated", socket.assigns)
  #   {:noreply, socket}
  # end

  # @impl true
  # def handle_event(event, params, socket) do
  #   IO.inspect({event, params}, label: "Got unknown event")
  #   {:noreply, socket}
  # end

  defp compute_filter_info(todos) do
    active_count = todos |> Enum.count(fn i -> i.status end)
    completed_count = todos |> Enum.count(fn i -> !i.status end)
    show_clear_completed = completed_count > 0
    remaining_items = length(todos) - active_count

    %{
      filter: nil,
      active_count: active_count,
      remaining_items: remaining_items,
      highlight_toggle: active_count == length(todos),
      completed_count: completed_count,
      show_clear_completed: show_clear_completed
    }
  end
end
