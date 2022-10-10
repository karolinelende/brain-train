defmodule BrainTrain.Scores do
  import Ecto.Query
  alias BrainTrain.Score
  alias BrainTrain.Repo

  def get_scores_for_game(game) do
    Repo.all(from s in Score, where: s.game == ^game)
  end

  def insert(attrs) do
    %Score{}
    |> Score.changeset(attrs)
    |> Repo.insert()
  end
end
