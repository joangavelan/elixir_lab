defmodule Expense do
  defstruct [:id, :amount, :category, :description, :date]
end

defmodule ExpenseTracker do
  use GenServer

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def log_expense(
        amount,
        category \\ "Uncategorized",
        description \\ "",
        date \\ Date.utc_today()
      )

  def log_expense(amount, category, description, date) when is_number(amount) and amount > 0 do
    GenServer.call(__MODULE__, {:log_expense, amount, category, description, date})
  end

  def log_expense(_amount, _category, _description, _date) do
    {:error, :invalid_amount}
  end

  # Server callbacks
  @impl true
  def init(_) do
    {:ok, []}
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

    {:reply, {:ok, new_expense}, [new_expense | expenses]}
  end
end
