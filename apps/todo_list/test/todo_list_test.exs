defmodule TodoListTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = TodoList.start_link([])
    :ok
  end

  test "adds a valid todo" do
    assert {:ok, todo} = TodoList.add_todo("Learn Elixir")
    assert todo.name == "Learn Elixir"
    assert [^todo] = TodoList.list_todos()
  end

  test "does not add a todo with an invalid name" do
    assert {:error, "Invalid todo name"} = TodoList.add_todo("")
    assert [] = TodoList.list_todos()
  end

  test "list all todos" do
    {:ok, todo1} = TodoList.add_todo("Todo 1")
    {:ok, todo2} = TodoList.add_todo("Todo 2")
    todos = TodoList.list_todos()
    assert length(todos) == 2
    assert Enum.any?(todos, &(&1.id == todo1.id))
    assert Enum.any?(todos, &(&1.id == todo2.id))
  end

  test "toggles completion status of a todo" do
    {:ok, todo} = TodoList.add_todo("Complete a task")
    assert not todo.completed

    :ok = TodoList.toggle_todo_completion(todo.id)
    [updated_todo] = TodoList.list_todos()
    assert updated_todo.completed

    :ok = TodoList.toggle_todo_completion(todo.id)
    [toggled_back_todo] = TodoList.list_todos()
    assert not toggled_back_todo.completed
  end

  test "deletes a todo by id" do
    {:ok, todo} = TodoList.add_todo("Todo to delete")
    assert length(TodoList.list_todos()) == 1

    :ok = TodoList.delete_todo(todo.id)
    assert [] = TodoList.list_todos()
  end

  test "delete operation returns error for a non-existent id" do
    {:ok, todo} = TodoList.add_todo("Keep this todo")
    assert length(TodoList.list_todos()) == 1

    assert {:error, "Todo not found"} = TodoList.delete_todo("non-existent-id")
    assert [^todo] = TodoList.list_todos()
  end
end
