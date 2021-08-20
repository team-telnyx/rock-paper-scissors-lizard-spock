defmodule CallControl.Game do
  use GenServer

  alias __MODULE__.Move

  def start_link(_ \\ nil) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %{}}
  end

  @spec join(pid(), any()) :: :ok | {:error, atom()}
  def join(game, player_id) do
    GenServer.call(game, {:join, player_id})
  end

  @spec play(pid(), any(), Move.t()) :: :ok | {:error, atom()}
  def play(game, player_id, move) do
    GenServer.call(game, {:play, player_id, move})
  end

  @spec result(pid()) :: {:ok, {:win, any(), binary()} | :draw} | {:error, :not_played}
  def result(game) do
    GenServer.call(game, :result)
  end

  @spec opponent_move(pid(), any()) :: Move.t() | nil
  def opponent_move(game, player_id) do
    GenServer.call(game, {:opponent_move, player_id})
  end

  @spec players(pid) :: list(any())
  def players(game) do
    GenServer.call(game, :players)
  end

  @spec status(pid) :: :waiting | :ready | :ongoing | :finished
  def status(game) do
    GenServer.call(game, :status)
  end

  def handle_call({:join, player_id}, _, players) do
    cond do
      Enum.count(players) == 2 ->
        {:reply, {:error, :game_full}, players}

      player_id in Map.keys(players) ->
        {:reply, {:error, :already_joined}, players}

      true ->
        {:reply, :ok, Map.put(players, player_id, nil)}
    end
  end

  def handle_call({:play, player_id, move}, _, players) do
    case Map.fetch(players, player_id) do
      {:ok, nil} ->
        {:reply, :ok, Map.put(players, player_id, move)}

      {:ok, _} ->
        {:reply, {:error, :already_played}, players}

      :error ->
        {:reply, {:error, :bad_player}, players}
    end
  end

  def handle_call({:opponent_move, player_id}, _, players) do
    move =
      case Enum.find(players, fn {id, _} -> id != player_id end) do
        {_, move} -> move
        _ -> nil
      end

    {:reply, move, players}
  end

  def handle_call(:result, _, players) do
    [{player_1, move_1}, {player_2, move_2}] = Enum.map(players, & &1)

    if is_nil(move_1) || is_nil(move_2) do
      {:reply, {:error, :not_played}, players}
    else
      case Move.compare(move_1, move_2) do
        {:gt, reason} ->
          {:reply, {:ok, {:win, player_1, reason}}, players}

        {:lt, reason} ->
          {:reply, {:ok, {:win, player_2, reason}}, players}

        :eq ->
          {:reply, {:ok, :draw}, players}
      end
    end
  end

  def handle_call(:players, _, players) do
    {:reply, Map.keys(players), players}
  end

  def handle_call(:status, _, players) do
    status =
      cond do
        Enum.count(players) < 2 ->
          :waiting

        Map.values(players) == [nil, nil] ->
          :ready

        nil in Map.values(players) ->
          :ongoing

        true ->
          :finished
      end

    {:reply, status, players}
  end
end
