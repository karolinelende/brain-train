defmodule BrainTrain.SpeedSort do
  def generate_list_of_numbers() do
    Stream.repeatedly(fn -> :rand.uniform(100) end) |> Stream.uniq() |> Enum.take(5)
  end

  def check_next_in_list(numbers, _number) when length(numbers) == 1 do
    {:ok, "Good job!"}
  end

  def check_next_in_list(numbers, number) do
    [correct_answer | _] = Enum.sort(numbers, :asc)

    if number == correct_answer do
      List.delete(numbers, number)
    else
      {:error, "Wrong number!"}
    end
  end
end
