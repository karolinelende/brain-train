defmodule SpeedSortTest do
  use ExUnit.Case, async: true
  alias BrainTrain.SpeedSort

  describe "check_next_in_list/3" do
    test "when only one item left in list, returns success message" do
      assert {:ok, "Good job!"} == SpeedSort.check_next_in_list([4], nil)
    end

    test "when correct guess, returns the list without that number" do
      list = [5, 6, 9, 2, 4]

      assert [5, 6, 9, 4] == SpeedSort.check_next_in_list(list, 2)
    end

    test "when wrong guess, returns error message" do
      list = [5, 6, 9, 2, 4]

      assert {:error, "Wrong number!"} == SpeedSort.check_next_in_list(list, 6)
    end
  end
end
