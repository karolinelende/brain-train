defmodule BrainTrain.TicTacToe.Square do
  alias __MODULE__

  defstruct name: nil, letter: nil

  @type t :: %Square{
          name: nil | atom(),
          letter: nil | String.t()
        }

  def build(name, letter \\ nil) do
    %Square{name: name, letter: letter}
  end

  def is_open?(%Square{letter: nil}), do: true
  def is_open?(%Square{}), do: false
end
