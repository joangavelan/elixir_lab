defmodule Game do
  defstruct [:target, :remaining_guesses]
end

defmodule GuessTheNumber do
  def start_game do
    game = %Game{target: Enum.random(1..100), remaining_guesses: 5}
    {:ok, game}
  end

  def guess(%Game{remaining_guesses: 0} = _game, _guess) do
    {:error, "No guesses left. Start a new game"}
  end

  def guess(_game, guess) when guess < 1 or guess > 100 do
    {:error, "Invalid guess. Must be between 1 and 100."}
  end

  def guess(%Game{target: target} = game, guess) when target == guess do
    {:correct, game}
  end

  def guess(%Game{target: target} = game, guess) when guess > target or guess < target do
    game = %{game | remaining_guesses: game.remaining_guesses - 1}

    cond do
      game.remaining_guesses == 0 -> {:lost, game}
      guess > target -> {:high, game}
      guess < target -> {:low, game}
    end
  end
end
