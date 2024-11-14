defmodule Todo do
  @enforce_keys [:name]
  defstruct id: nil,
            name: "",
            completed: false,
            created_at: Date.utc_today()
end

defmodule TodoList do
  use GenServer

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_todo(todo_name) when is_binary(todo_name) and todo_name != "" do
    GenServer.call(__MODULE__, {:add_todo, todo_name})
  end

  def add_todo(_invalid_name), do: {:error, "Invalid todo name"}

  def toggle_todo_completion(todo_id) do
    GenServer.call(__MODULE__, {:toggle_todo_completion, todo_id})
  end

  def delete_todo(todo_id) do
    GenServer.call(__MODULE__, {:delete_todo, todo_id})
  end

  def list_todos do
    GenServer.call(__MODULE__, :list_todos)
  end

  # Server callbacks
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call({:add_todo, todo_name}, _from, todos) do
    new_todo = %Todo{
      id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      name: todo_name
    }

    {:reply, {:ok, new_todo}, [new_todo | todos]}
  end

  @impl true
  def handle_call({:toggle_todo_completion, todo_id}, _from, todos) do
    updated_todos =
      Enum.map(todos, fn todo ->
        if todo.id == todo_id do
          %{todo | completed: !todo.completed}
        else
          todo
        end
      end)

    {:reply, :ok, updated_todos}
  end

  @impl true
  def handle_call({:delete_todo, todo_id}, _from, todos) do
    case Enum.find(todos, &(&1.id == todo_id)) do
      nil -> {:reply, {:error, "Todo not found"}, todos}
      _ -> {:reply, :ok, Enum.filter(todos, &(&1.id != todo_id))}
    end
  end

  @impl true
  def handle_call(:list_todos, _from, todos) do
    {:reply, todos, todos}
  end
end
