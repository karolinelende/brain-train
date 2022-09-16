defmodule BrainTrain.SpeedSort do
  def generate_list_of_numbers() do
    Stream.repeatedly(fn -> :rand.uniform(100) end) |> Stream.uniq() |> Enum.take(5)
  end

  def check_next_in_list(numbers, number, index) do
    [correct_answer | _] = Enum.sort(numbers, :asc)

    if number == correct_answer do
      new_numbers = List.delete(numbers, index)

      {:ok, new_numbers}
    else
      {:error, "Wrong number!"}
    end
  end
end
