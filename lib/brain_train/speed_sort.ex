defmodule BrainTrain.SpeedSort do
  def list_length, do: 6

  def generate_list_of_numbers() do
    Stream.repeatedly(fn -> :rand.uniform(100) end)
    |> Stream.uniq()
    |> Enum.take(list_length())
    |> Enum.sort(:asc)
    |> Enum.with_index()
    |> Enum.shuffle()
  end
end
