defmodule BrainTrain.Scores do
  import Ecto.Query
  alias BrainTrain.Score
  alias BrainTrain.Repo

  def top_scores(number) do
    Repo.all(from(s in Score, order_by: [desc: s.score], limit: ^number))
  end

  def maybe_append_top_score(existing_scores, new_score, rank) do
    if length(existing_scores) < rank do
      append_and_sort(existing_scores, new_score)
    else
      %{score: lowest_score} = List.last(existing_scores)

      if new_score.score > lowest_score do
        append_and_sort(existing_scores, new_score) |> Enum.take(rank)
      else
        existing_scores
      end
    end
  end

  def append_and_sort(existing_scores, new_score) do
    [new_score | existing_scores] |> Enum.sort_by(& &1.score, :desc)
  end

  def get_scores_for_game(game, limit \\ 10) do
    Repo.all(from s in Score, order_by: [desc: s.score], where: s.game == ^game, limit: ^limit)
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
