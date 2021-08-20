defmodule CallControl.GameTest do
  use ExUnit.Case

  alias CallControl.Game

  describe "join/2" do
    setup do
      {:ok, game} = start_supervised(Game)
      {:ok, game: game}
    end

    test "adds player to the game", %{game: game} do
      assert :ok = Game.join(game, "player1")
      assert :ok = Game.join(game, "player2")
    end

    test "cannot join twice", %{game: game} do
      :ok = Game.join(game, "player1")
      assert {:error, :already_joined} = Game.join(game, "player1")
    end

    test "cannot add more than two players", %{game: game} do
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      assert {:error, :game_full} = Game.join(game, "player3")
    end
  end

  describe "play/3" do
    setup do
      {:ok, game} = start_supervised(Game)
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      {:ok, game: game}
    end

    test "registers player's move", %{game: game} do
      assert :ok = Game.play(game, "player1", :rock)
      assert :ok = Game.play(game, "player2", :paper)
    end

    test "cannot play twice", %{game: game} do
      :ok = Game.play(game, "player1", :rock)
      assert {:error, :already_played} = Game.play(game, "player1", :paper)
    end

    test "cannot play without joining", %{game: game} do
      assert {:error, :bad_player} = Game.play(game, "player3", :paper)
    end
  end

  describe "result/1" do
    setup do
      {:ok, game} = start_supervised(Game)
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      {:ok, game: game}
    end

    test "returns error when not all players made their moves", %{game: game} do
      assert {:error, :not_played} = Game.result(game)
      :ok = Game.play(game, "player1", :rock)
      assert {:error, :not_played} = Game.result(game)
    end

    test "reports player1's win", %{game: game} do
      :ok = Game.play(game, "player1", :rock)
      :ok = Game.play(game, "player2", :scissors)
      assert {:ok, {:win, "player1", "Rock crushes scissors"}}
    end

    test "reports player2's win", %{game: game} do
      :ok = Game.play(game, "player1", :rock)
      :ok = Game.play(game, "player2", :spock)
      assert {:ok, {:win, "player2", "Spock vaporizes rock"}}
    end

    test "reports draw", %{game: game} do
      :ok = Game.play(game, "player1", :rock)
      :ok = Game.play(game, "player2", :rock)
      assert {:ok, :draw}
    end
  end

  describe "players/1" do
    setup do
      {:ok, game} = start_supervised(Game)
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      {:ok, game: game}
    end

    test "returns list of players", %{game: game} do
      assert Game.players(game) |> Enum.sort() == ["player1", "player2"]
    end
  end

  describe "opponent_move/2" do
    setup do
      {:ok, game} = start_supervised(Game)
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      :ok = Game.play(game, "player1", :rock)
      {:ok, game: game}
    end

    test "returns opponent's move", %{game: game} do
      assert Game.opponent_move(game, "player1") == nil
      assert Game.opponent_move(game, "player2") == :rock
    end
  end

  describe "status/1" do
    setup do
      {:ok, game} = start_supervised(Game)
      {:ok, game: game}
    end

    test "is waiting when there are less than two players", %{game: game} do
      assert :waiting = Game.status(game)
      :ok = Game.join(game, "player1")
      assert Game.status(game) == :waiting
    end

    test "is ready when there are two players", %{game: game} do
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      assert Game.status(game) == :ready
    end

    test "is ongoing when only one player made a move", %{game: game} do
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      :ok = Game.play(game, "player2", :rock)
      assert Game.status(game) == :ongoing
    end

    test "is finished when both players made their moves", %{game: game} do
      :ok = Game.join(game, "player1")
      :ok = Game.join(game, "player2")
      :ok = Game.play(game, "player1", :rock)
      :ok = Game.play(game, "player2", :scissors)
      assert Game.status(game) == :finished
    end
  end
end
