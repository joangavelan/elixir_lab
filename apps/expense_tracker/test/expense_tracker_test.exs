defmodule ExpenseTrackerTest do
  use ExUnit.Case
  doctest ExpenseTracker

  @test_db_file "test/fixtures/expenses.csv"

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

  describe "list_expenses/0" do
    test "returns an empty list when there are no expenses" do
      assert ExpenseTracker.list_expenses() == []
    end

    test "returns a list of logged expenses" do
      {:ok, expense1} = ExpenseTracker.log_expense(50.75, "Food", "Lunch", ~D[2024-11-17])
      {:ok, expense2} = ExpenseTracker.log_expense(20.00, "Transport", "Bus fare", ~D[2024-11-16])

      expenses = ExpenseTracker.list_expenses()

      assert length(expenses) == 2
      assert Enum.any?(expenses, &(&1.id == expense1.id))
      assert Enum.any?(expenses, &(&1.id == expense2.id))
    end

    test "returns expenses sorted by date in descending order" do
      ExpenseTracker.log_expense(50.75, "Food", "Lunch with friends", ~D[2024-11-15])
      ExpenseTracker.log_expense(20.00, "Transport", "Bus fare", ~D[2024-11-17])
      ExpenseTracker.log_expense(10.00, "Snacks", "Chips", ~D[2024-11-16])

      expenses = ExpenseTracker.list_expenses()
      dates = Enum.map(expenses, & &1.date)

      assert dates == [~D[2024-11-17], ~D[2024-11-16], ~D[2024-11-15]]
    end
  end

  describe "delete_expense/1" do
    test "deletes an existing expense and returns the deleted expense" do
      {:ok, expense} = ExpenseTracker.log_expense(50.00)
      assert {:ok, deleted_expense} = ExpenseTracker.delete_expense(expense.id)
      assert deleted_expense == expense
      assert ExpenseTracker.list_expenses() == []
    end

    test "returns a descriptive error message when trying to delete a non-existent expense" do
      invalid_id = "non-existent-id"

      assert {:error, "Couldn't find expense with id: #{invalid_id}"} ==
               ExpenseTracker.delete_expense(invalid_id)
    end

    test "returns an error when the provided id is invalid" do
      assert {:error, :invalid_id} = ExpenseTracker.delete_expense(nil)
    end
  end

  describe "export_expenses_to_csv/2" do
    test "writes the correct CSV data to the file" do
      expenses = [
        %Expense{
          id: "1",
          amount: 50.75,
          category: "Food",
          description: "Lunch",
          date: ~D[2024-11-22]
        },
        %Expense{
          id: "2",
          amount: 20.00,
          category: "Transport",
          description: "Bus fare",
          date: ~D[2024-11-23]
        }
      ]

      ExpenseTracker.export_expenses_to_csv(expenses, @test_db_file)

      file_content = File.read!(@test_db_file)

      expected_content =
        """
        id,amount,category,description,date
        1,50.75,Food,Lunch,2024-11-22
        2,20.0,Transport,Bus fare,2024-11-23
        """
        |> String.trim()

      assert file_content == expected_content
    end
  end

  describe "import_expenses_from_csv/1" do
    test "reads the file and reconstructs the expenses list" do
      # Create a sample CSV file
      File.write!(@test_db_file, """
      id,amount,category,description,date
      1,50.75,Food,Lunch,2024-11-22
      2,20.0,Transport,Bus fare,2024-11-23
      """)

      # Call the function to import the expenses
      expenses = ExpenseTracker.import_expenses_from_csv(@test_db_file)

      # Expected list of expenses
      expected_expenses = [
        %Expense{
          id: "1",
          amount: 50.75,
          category: "Food",
          description: "Lunch",
          date: ~D[2024-11-22]
        },
        %Expense{
          id: "2",
          amount: 20.00,
          category: "Transport",
          description: "Bus fare",
          date: ~D[2024-11-23]
        }
      ]

      assert expenses == expected_expenses
    end

    test "returns an empty list when the CSV file is empty" do
      # Create an empty CSV file
      File.write!(@test_db_file, "")

      # Call the function to import the expenses
      expenses = ExpenseTracker.import_expenses_from_csv(@test_db_file)

      assert expenses == []
    end
  end
end
