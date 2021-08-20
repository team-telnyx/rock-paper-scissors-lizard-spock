defmodule CallControl.Game.Move do
  @type t :: :rock | :paper | :scissors | :lizard | :spock

  @moves [:rock, :paper, :scissors, :lizard, :spock]

  @spec recognize(any()) :: {:ok, t()} | {:error, atom()}
  def recognize("1"), do: {:ok, :rock}
  def recognize("2"), do: {:ok, :paper}
  def recognize("3"), do: {:ok, :scissors}
  def recognize("4"), do: {:ok, :lizard}
  def recognize("5"), do: {:ok, :spock}
  def recognize(_), do: {:error, :unrecognized_move}

  @spec compare(t(), t()) :: {:gt | :lt, binary()} | :eq
  def compare(:paper, :rock), do: {:gt, "Paper covers rock"}
  def compare(:paper, :spock), do: {:gt, "Paper disproves Spock"}
  def compare(:rock, :scissors), do: {:gt, "Rock crushes scissors"}
  def compare(:rock, :lizard), do: {:gt, "Rock crushes lizard"}
  def compare(:scissors, :lizard), do: {:gt, "Scissors decapitate lizard"}
  def compare(:scissors, :paper), do: {:gt, "Scissors cuts paper"}
  def compare(:lizard, :paper), do: {:gt, "Lizard eats paper"}
  def compare(:lizard, :spock), do: {:gt, "Lizard poisons Spock"}
  def compare(:spock, :rock), do: {:gt, "Spock vaporizes rock"}
  def compare(:spock, :scissors), do: {:gt, "Spock smashes scissors"}
  def compare(move1, move2) when move1 == move2, do: :eq

  def compare(move1, move2) do
    {_, reason} = compare(move2, move1)
    {:lt, reason}
  end

  @spec random_reply(t) :: t
  def random_reply(move) do
    Enum.random(@moves -- [move])
  end
end
