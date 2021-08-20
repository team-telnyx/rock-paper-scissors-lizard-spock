defmodule CallControl.GameServerTest do
  use ExUnit.Case

  alias CallControl.GameServer

  setup do
    {:ok, game_server} = GenServer.start_link(GameServer, nil)
    {:ok, game_server: game_server}
  end

  describe "connect/1" do
    test "matches players in games of two", %{game_server: game_server} do
      assert {:ok, game_1_id, game_1} = GenServer.call(game_server, {:connect, "player1"})
      assert {:ok, ^game_1_id, ^game_1} = GenServer.call(game_server, {:connect, "player2"})
      assert {:ok, game_2_id, game_2} = GenServer.call(game_server, {:connect, "player3"})
      assert game_1_id != game_2_id
      assert game_1 != game_2
    end
  end

  describe "get_game/1" do
    test "finds game by id", %{game_server: game_server} do
      {:ok, game_id, game} = GenServer.call(game_server, {:connect, "player1"})
      {:ok, ^game_id, ^game} = GenServer.call(game_server, {:connect, "player2"})
      assert {:ok, ^game} = GenServer.call(game_server, {:get_game, game_id})
    end

    test "returns error when game cannot be found", %{game_server: game_server} do
      assert {:error, :game_not_found} = GenServer.call(game_server, {:get_game, "bad"})
    end

    test "returns error when game does not have two players", %{game_server: game_server} do
      {:ok, game_id, _} = GenServer.call(game_server, {:connect, "player1"})
      assert {:error, :game_not_started} = GenServer.call(game_server, {:get_game, game_id})
    end
  end
end
