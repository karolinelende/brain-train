defmodule BrainTrain.SpeedSort do
  def db_name, do: "speed_sort"

  def list_length, do: 6

  def generate_list_of_numbers() do
    Stream.repeatedly(fn -> :rand.uniform(100) end)
    |> Stream.uniq()
    |> Enum.take(list_length())
    |> Enum.sort(:asc)
    |> Enum.with_index()
    |> Enum.shuffle()
  end

  def calculate_score(existing_score, elapsed_time, :correct),
    do: round(existing_score + 10 + 20 / elapsed_time)

  def calculate_score(existing_score, _elapsed_time, :incorrect),
    do: round(existing_score - 5)
end
