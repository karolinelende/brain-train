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
    |> broadcast(:score_saved)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(BrainTrain.PubSub, "scores")
  end

  def broadcast({:ok, score}, event) do
    Phoenix.PubSub.broadcast(BrainTrain.PubSub, "scores", {event, score})
    {:ok, score}
  end

  def broadcast({:error, _reason} = error, _event), do: error
end
