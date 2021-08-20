defmodule CallControl.SinglePlayer do
  alias CallControl.Game.Move

  def handle(%{"Digits" => digit}) do
    {:ok, move} = Move.recognize(digit)
    opponent_move = Move.random_reply(move)

    {result, audio_file} =
      case Move.compare(move, opponent_move) do
        {:gt, reason} ->
          {"You won, because #{reason}", "applause.mp3"}

        {:lt, reason} ->
          {"You lost, because #{reason}", "boo.wav"}
      end

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <Response>
      <Say voice="alice">
        You chose #{move}. Your opponent chose #{opponent_move}.
        #{result}
      </Say>
      <Play>#{Application.get_env(:call_control, :host) <> "/" <> audio_file}</Play>
      <Hangup />
    </Response>
    """
  end

  def handle(_) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <Response>
      <Say voice="alice">Welcome to the game of rock, paper, scissors, lizard, spock.</Say>
      <Gather action="/webhook/singleplayer" numDigits="1" validDitgits="12345">
        <Say voice="alice">Make your move. Press 1 for rock, 2 for paper, 3 for scissors, 4 for lizard, 5 for spock.</Say>
      </Gather>
    </Response>
    """
  end
end
