defmodule CallControl.MultiPlayer do
  alias CallControl.API
  alias CallControl.Game
  alias CallControl.Game.Move
  alias CallControl.GameServer

  def handle(%{"data" => %{"event_type" => "call.initiated", "payload" => payload}}) do
    caller = get_caller(payload)

    case GameServer.connect(caller) do
      {:ok, game_id, _} ->
        API.answer_call(caller, game_id)

      {:error, _reason} ->
        API.reject_call(caller)
    end
  end

  def handle(%{"data" => %{"event_type" => "call.answered", "payload" => payload}}) do
    caller = get_caller(payload)
    game_id = get_game_id(payload)

    API.speak_text(
      caller,
      "Welcome to the game of rock, paper, scissors, lizard, spock."
    )

    with {:ok, game} <- GameServer.get_game(game_id) do
      case Game.status(game) do
        :waiting ->
          API.speak_text(caller, "Let's wait for your opponent.")

        :ready ->
          for player <- Game.players(game) do
            if player != caller, do: API.speak_text(player, "The opponent has joined.")

            API.speak_text(
              player,
              "Make your move. Press 1 for rock, 2 for paper, 3 for scissors, 4 for lizard, 5 for spock."
            )
          end

        _ ->
          :noop
      end
    end
  end

  def handle(%{"data" => %{"event_type" => "call.dtmf.received", "payload" => payload}}) do
    caller = get_caller(payload)
    game_id = get_game_id(payload)

    with {:ok, game} <- GameServer.get_game(game_id),
         {:ok, move} <- Move.recognize(payload["digit"]),
         :ok <- Game.play(game, caller, move) do
      API.speak_text(caller, "You chose #{move}.")

      case Game.status(game) do
        :ongoing ->
          :noop

        :finished ->
          {:ok, result} = Game.result(game)

          for player <- Game.players(game) do
            opponent_move = Game.opponent_move(game, player)
            API.speak_text(player, "Your opponent chose #{opponent_move}")

            case result do
              {:win, ^player, reason} ->
                API.speak_text(player, "You won, because " <> reason)
                API.play_audio(player, "applause.mp3")

              {:win, _, reason} ->
                API.speak_text(player, "You lost, because " <> reason)
                API.play_audio(player, "boo.wav")

              :draw ->
                API.speak_text(player, "The game was drawn")
            end
          end

          # Wait until audio is played, then hang up
          # Though it would be better to perform this in `call.playback.ended` webhook handler
          :timer.sleep(15000)

          for player <- Game.players(game) do
            API.hangup_call(player)
          end

          GameServer.stop_game(game_id)
      end
    else
      {:error, :game_not_found} ->
        API.speak_text(caller, "Your game has crashed, we need to disconnect.")
        API.hangup_call(caller)

      {:error, :game_not_started} ->
        API.speak_text(caller, "Hold your horses! Your opponent has not joined yet.")

      _ ->
        :noop
    end
  end

  def handle(%{"data" => %{"event_type" => "call.hangup", "payload" => payload}}) do
    caller = get_caller(payload)
    game_id = get_game_id(payload)

    with {:ok, game} <- GameServer.get_game(game_id) do
      for player <- Game.players(game), player != caller do
        API.hangup_call(player)
        GameServer.stop_game(game_id)
      end
    end
  end

  def handle(_), do: :noop

  defp get_caller(%{"call_control_id" => id}), do: id
  defp get_game_id(%{"client_state" => client_state}), do: client_state
end
