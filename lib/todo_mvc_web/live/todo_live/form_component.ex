defmodule TodoMvcWeb.TodoLive.FormComponent do
  use TodoMvcWeb, :live_component
  use Constants

  alias TodoMvc.Todos
  alias TodoMvc.Todos.Todo

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> Todos.change_todo(todo_params)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("toggle_all", _, socket) do
    # IO.inspect(_)
    # if at least one todo is not completed, then we want to complete all
    # otherwise, we want to uncomplete all
    case Todos.list_todos() |> Enum.all?(fn todo -> todo.status end) do
      true ->
        Todos.update_all(status: false)

      false ->
        Todos.update_all(status: true)
    end

    socket =
      assign(socket, todos: Todos.list_todos())

    TodoMvcWeb.Endpoint.broadcast(@todos_topic, "todos_updated", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_todo", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> Todos.change_todo(todo_params)

    case Todos.create_todo(todo_params) do
      {:ok, _todo} ->
        socket =
          assign(socket, todos: Todos.list_todos())
          # resets the form
          |> assign(form: to_form(Todos.change_todo(%Todo{})))

        TodoMvcWeb.Endpoint.broadcast(@todos_topic, "todos_updated", socket.assigns)

        {:noreply, socket}

      {:error, _todo} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: "Got unknown event")
    {:noreply, socket}
  end

  # custom component for todo form
  attr :name, :any
  attr :value, :any, default: nil

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def todo_input(assigns) do
    ~H"""
    <div class="flex-auto pr-4 pt-1">
      <input
        type="text"
        name={@name}
        id={"#{@name}_text"}
        value={Phoenix.HTML.Form.normalize_value("text", @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 ",
          "sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 ",
          "phx-no-feedback:focus:border-zinc-400 border-zinc-300 ",
          "focus:border-zinc-400 border-0 placeholder:italic ",
          "placeholder:text-slate-400 placeholder:text-xl text-xl sm:text-xl"
        ]}
        {@rest}
      />
    </div>
    """
  end

  @doc """
  Renders a simple form for the todo.
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def todo_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-0 space-y-0 pr-4 w-full">
        <%= render_slot(@inner_block, f) %>
      </div>
    </.form>
    """
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
