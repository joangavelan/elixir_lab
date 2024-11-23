defmodule Expense do
  defstruct [:id, :amount, :category, :description, :date]
end

defmodule ExpenseTracker do
  use GenServer

  @db_file "db/expenses.csv"

  # Client API
  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def log_expense(
        amount,
        category \\ "Uncategorized",
        description \\ "",
        date \\ Date.utc_today()
      )

  def log_expense(amount, category, description, date) when is_float(amount) and amount > 0 do
    GenServer.call(__MODULE__, {:log_expense, amount, category, description, date})
  end

  def log_expense(_amount, _category, _description, _date) do
    {:error, :invalid_amount}
  end

  def list_expenses do
    GenServer.call(__MODULE__, :list_expenses)
  end

  def delete_expense(id) when is_binary(id) do
    GenServer.call(__MODULE__, {:delete_expense, id})
  end

  def delete_expense(_id) do
    {:error, :invalid_id}
  end

  def export_expenses do
    GenServer.call(__MODULE__, :export_expenses)
  end

  def export_expenses_to_csv(expenses, file_path) do
    header = ["id,amount,category,description,date"]
    rows = Enum.map(expenses, &expense_to_csv_row/1)

    csv_data = [header | rows] |> Enum.join("\n")
    File.write!(file_path, csv_data)
  end

  defp expense_to_csv_row(%Expense{
         id: id,
         amount: amount,
         category: category,
         description: description,
         date: date
       }) do
    Enum.join([id, amount, category, description, date], ",")
  end

  def import_expenses_from_csv(file_path) do
    case File.read!(file_path) do
      "" -> []
      content -> parse_file_content(content)
    end
  end

  defp parse_file_content(content) do
    content
    |> String.split("\n", trim: true)
    |> List.delete_at(0)
    |> Enum.map(&parse_expense/1)
  end

  defp parse_expense(str_expense) do
    [id, amount, category, description, date] = String.split(str_expense, ",")

    %Expense{
      id: id,
      amount: String.to_float(amount),
      category: category,
      description: description,
      date: Date.from_iso8601!(date)
    }
  end

  # Server callbacks
  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:log_expense, amount, category, description, date}, _from, expenses) do
    new_expense = %Expense{
      id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      amount: amount,
      category: category,
      description: description,
      date: date
    }

    expenses = [new_expense | expenses]
    {:reply, {:ok, new_expense}, expenses}
  end

  @impl true
  def handle_call(:list_expenses, _from, expenses) do
    expenses_sorted_by_date = Enum.sort_by(expenses, & &1.date, {:desc, Date})
    {:reply, expenses_sorted_by_date, expenses}
  end

  @impl true
  def handle_call({:delete_expense, id}, _from, expenses) do
    case Enum.find(expenses, &(&1.id == id)) do
      nil ->
        {:reply, {:error, "Couldn't find expense with id: #{id}"}, expenses}

      expense ->
        filtered_expenses = Enum.filter(expenses, &(&1.id != id))
        {:reply, {:ok, expense}, filtered_expenses}
    end
  end

  @impl true
  def handle_call(:export_expenses, _from, expenses) do
    export_expenses_to_csv(expenses, @db_file)
    {:reply, {:ok, "Expenses exported successfully"}, expenses}
  end
end
