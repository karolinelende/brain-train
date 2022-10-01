defmodule SpeedSortTest do
  use ExUnit.Case, async: true
  alias BrainTrain.SpeedSort

  describe "generate_list_of_numbers/0" do
    test "generates an indexed list of 6 numbers" do
      list = SpeedSort.generate_list_of_numbers()

      assert [{_, _}, {_, _}, {_, _}, {_, _}, {_, _}, {_, _}] = list
    end
  end
end
