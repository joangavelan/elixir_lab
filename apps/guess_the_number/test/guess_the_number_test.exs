defmodule GuessTheNumberTest do
  use ExUnit.Case
  alias GuessTheNumber

  describe "start_game/0" do
    test "initializes the game state with a random number between 1 and 100" do
      {:ok, game} = GuessTheNumber.start_game()
      assert game.target >= 1 and game.target <= 100
    end

    test "initializes the game state with 5 remaining guesses" do
      {:ok, game} = GuessTheNumber.start_game()
      assert game.remaining_guesses == 5
    end
  end

  describe "guess/2" do
    setup do
      {:ok, game} = GuessTheNumber.start_game()
      # Manually set the target to 50 for predictable testing
      game = %{game | target: 50}
      {:ok, %{game: game}}
    end

    test "returns :correct when the guess matches the target", %{game: game} do
      assert {:correct, ^game} = GuessTheNumber.guess(game, 50)
    end

    test "returns :low when the guess is too low", %{game: game} do
      assert {:low, _updated_game} = GuessTheNumber.guess(game, 25)
    end

    test "returns :high when the guess is too high", %{game: game} do
      assert {:high, _updated_game} = GuessTheNumber.guess(game, 75)
    end

    test "decrements remaining guesses on each guess", %{game: game} do
      initial_guesses = game.remaining_guesses
      {:low, updated_game} = GuessTheNumber.guess(game, 25)
      assert updated_game.remaining_guesses == initial_guesses - 1
    end

    test "returns :lost when no guesses remain", %{game: game} do
      # Set to one guess for this test
      game = %{game | remaining_guesses: 1}
      assert {:lost, _updated_game} = GuessTheNumber.guess(game, 25)
    end
  end

  describe "validations" do
    setup do
      # Manually set the target to 50 for predictable testing
      {:ok, game} = GuessTheNumber.start_game()
      game = %{game | target: 50}
      {:ok, %{game: game}}
    end

    test "rejects guesses outside the valid range (1 to 100)", %{game: game} do
      assert {:error, "Invalid guess. Must be between 1 and 100."} = GuessTheNumber.guess(game, 0)

      assert {:error, "Invalid guess. Must be between 1 and 100."} =
               GuessTheNumber.guess(game, 101)
    end

    test "returns an error when a guess is made with no guesses left", %{game: game} do
      game = %{game | remaining_guesses: 0}

      assert {:error, "No guesses left. Start a new game"} = GuessTheNumber.guess(game, 25)
    end
  end
end
