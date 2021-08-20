defmodule CallControl.Game.MoveTest do
  use ExUnit.Case

  alias CallControl.Game.Move

  describe "recognize/1" do
    test "translates digit to atom representing a move" do
      assert {:ok, :paper} = Move.recognize("2")
      assert {:ok, :spock} = Move.recognize("5")
    end

    test "responds with error for unrecognized digit" do
      assert {:error, :unrecognized_move} = Move.recognize("8")
    end
  end

  describe "compare/2" do
    test "compares two moves" do
      assert {:gt, "Rock crushes scissors"} = Move.compare(:rock, :scissors)
      assert {:lt, "Lizard eats paper"} = Move.compare(:paper, :lizard)
      assert :eq = Move.compare(:spock, :spock)
    end
  end

  describe "random_reply/1" do
    test "returns a move different to given" do
      assert Move.random_reply(:spock) != :spock
    end
  end
end
