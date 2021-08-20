defmodule CallControl.GameServer do
  use GenServer

  alias CallControl.Game

  @type game_id :: binary()

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{playing: %{}, waiting: nil}}
  end

  @spec connect(any()) :: {:ok, game_id(), pid()} | {:error, atom()}
  def connect(player_id) do
    GenServer.call(__MODULE__, {:connect, player_id})
  end

  @spec get_game(game_id()) :: {:ok, pid()} | {:error, atom()}
  def get_game(game_id) do
    GenServer.call(__MODULE__, {:get_game, game_id})
  end

  @spec stop_game(game_id()) :: :ok
  def stop_game(game_id) do
    GenServer.cast(__MODULE__, {:stop, game_id})
  end

  def handle_call({:connect, player_id}, _, %{playing: playing, waiting: nil} = state) do
    with {:ok, game} <- Game.start_link(),
         :ok <- Game.join(game, player_id) do
      game_id = generate_game_id()

      {:reply, {:ok, game_id, game}, %{playing: playing, waiting: {game_id, game}}}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:connect, player_id}, _, %{playing: playing, waiting: {game_id, game}} = state) do
    with :ok <- Game.join(game, player_id) do
      {:reply, {:ok, game_id, game}, %{playing: Map.put(playing, game_id, game), waiting: nil}}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:get_game, game_id}, _, %{waiting: {game_id, _}} = state) do
    {:reply, {:error, :game_not_started}, state}
  end

  def handle_call({:get_game, game_id}, _, %{playing: playing} = state) do
    case Map.fetch(playing, game_id) do
      {:ok, game} ->
        {:reply, {:ok, game}, state}

      :error ->
        {:reply, {:error, :game_not_found}, state}
    end
  end

  def handle_cast({:stop_game, game_id}, %{waiting: {game_id, game}} = state) do
    GenServer.stop(game, :normal)
    {:noreply, state}
  end

  def handle_cast({:stop_gaem, game_id}, %{playing: playing} = state) do
    with {:ok, game} <- Map.fetch(playing, game_id) do
      GenServer.stop(game, :normal)
    end

    {:noreply, state}
  end

  def handle_cast({:stop, game}, %{waiting: {_, game}} = state) do
    {:noreply, Map.put(state, :waiting, nil)}
  end

  def handle_cast({:stop, game}, %{playing: playing} = state) do
    playing =
      playing
      |> Enum.filter(fn
        {_, ^game} -> false
        _ -> true
      end)
      |> Enum.into(%{})

    {:noreply, Map.put(state, :playing, playing)}
  end

  defp generate_game_id do
    :rand.seed(:exsss)
    chars = "abcdefghoijklmnopqrstuvwxyz0123456789" |> String.split("", trim: true)
    game_id = Enum.reduce(1..16, "", fn _i, str -> str <> Enum.random(chars) end)
    Base.encode64(game_id)
  end
end
