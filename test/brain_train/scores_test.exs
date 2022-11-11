defmodule BrainTrain.ScoresTest do
  use BrainTrainWeb.ConnCase

  alias BrainTrain.Scores

  @attrs %{
    name: "Karoline",
    score: 1000,
    game: "speed_sort"
  }

  describe "top_scores/1" do
    test "gets the specified number of highest scores across all games" do
      Scores.insert(@attrs)
      Scores.insert(%{@attrs | score: 3})
      Scores.insert(%{@attrs | score: 10})
      Scores.insert(%{@attrs | score: -10})
      Scores.insert(%{@attrs | game: "echo", score: 100})

      assert [
               %{score: 1000, game: "speed_sort"},
               %{score: 100, game: "echo"},
               %{score: 10, game: "speed_sort"}
             ] = Scores.top_scores(3)
    end
  end

  describe "maybe_append_top_score/3" do
    test "appends when existing list is too short" do
      existing_scores = [@attrs, %{@attrs | score: 10}, %{@attrs | score: 3}]
      new_score = %{@attrs | score: 25}

      assert [
               %{score: 1000},
               %{score: 25},
               %{score: 10},
               %{score: 3}
             ] = Scores.maybe_append_top_score(existing_scores, new_score, 5)
    end

    test "does nothing if score is too low" do
      existing_scores = [@attrs, %{@attrs | score: 10}, %{@attrs | score: 3}]
      new_score = %{@attrs | score: -10}

      assert [
               %{score: 1000},
               %{score: 10},
               %{score: 3}
             ] = Scores.maybe_append_top_score(existing_scores, new_score, 3)
    end

    test "appends and replaces when score is high enough" do
      existing_scores = [@attrs, %{@attrs | score: 10}, %{@attrs | score: 3}]
      new_score = %{@attrs | score: 25}

      assert [
               %{score: 1000},
               %{score: 25},
               %{score: 10}
             ] = Scores.maybe_append_top_score(existing_scores, new_score, 3)
    end
  end

  describe "append_and_sort/2" do
    existing_scores = [@attrs, %{@attrs | score: 10}, %{@attrs | score: 3}]
    new_score = %{@attrs | score: 25}

    assert [
             %{score: 1000},
             %{score: 25},
             %{score: 10},
             %{score: 3}
           ] = Scores.append_and_sort(existing_scores, new_score)
  end

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
