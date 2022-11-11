defmodule BrainTrain.ScoresTest do
  use BrainTrainWeb.ConnCase

  alias BrainTrain.Scores

  @attrs %{
    name: "Karoline",
    score: 1000,
    game: "speed_sort"
  }

  describe "get_scores_for_game/1" do
    test "gets scores for specified game only" do
      Scores.insert(@attrs)
      Scores.insert(%{@attrs | game: "echo"})

      assert [
               %{
                 name: "Karoline",
                 score: 1000,
                 game: "speed_sort",
                 user_id: nil
               }
             ] = Scores.get_scores_for_game("speed_sort")
    end

    test "if scores do not exist returns empty list" do
      assert [] == Scores.get_scores_for_game("speed_sort")
    end
  end

  describe "insert/1" do
    test "with valid attrs, can insert" do
      assert {:ok,
              %{
                name: "Karoline",
                score: 1000,
                game: "speed_sort",
                user_id: nil
              }} = Scores.insert(@attrs)
    end
  end
end
