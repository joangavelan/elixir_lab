defmodule ExpenseTrackerTest do
  use ExUnit.Case
  doctest ExpenseTracker

  setup do
    {:ok, _pid} = ExpenseTracker.start_link([])
    :ok
  end

  describe "log_expense/4" do
    # Logging a valid expense
    test "log a valid expense with all fields" do
      assert {:ok, expense} =
               ExpenseTracker.log_expense(50.75, "Food", "Lunch with friends", ~D[2024-11-14])

      assert expense.amount == 50.75
      assert expense.description == "Lunch with friends"
      assert expense.category == "Food"
      assert expense.date == ~D[2024-11-14]
    end

    # Logging an expense with default description, category and date
    test "log an expense with default values for missing fields" do
      assert {:ok, expense} = ExpenseTracker.log_expense(20.00)
      assert expense.description == ""
      assert expense.category == "Uncategorized"
      assert expense.date == Date.utc_today()
    end

    # Handling invalid amount
    test "reject logging an expense with invalid amount" do
      assert {:error, :invalid_amount} = ExpenseTracker.log_expense(-10.00)
    end
  end
end
