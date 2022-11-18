defmodule BrainTrain.TicTacToe.GameState do
  @moduledoc """
  Model the game state for a tic-tac-toe game.
  """
  alias BrainTrain.TicTacToe.Square
  alias BrainTrain.TicTacToe.Player
  alias __MODULE__

  # The board's squares are addressible using an atom like this: `:sq11` for
  # "Square: Row 1, Column 1". Ths goes through `:sq33` for "Square: Row 3,
  # Column 3".
  defstruct code: nil,
            players: [],
            player_turn: nil,
            status: :not_started,
            timer_ref: nil,
            board: [
              # Row 1
              Square.build(:sq11),
              Square.build(:sq12),
              Square.build(:sq13),
              # Row 2
              Square.build(:sq21),
              Square.build(:sq22),
              Square.build(:sq23),
              # Row 3
              Square.build(:sq31),
              Square.build(:sq32),
              Square.build(:sq33)
            ]

  @type game_code :: String.t()

  @type t :: %GameState{
          code: nil | String.t(),
          status: :not_started | :playing | :done,
          players: [Player.t()],
          player_turn: nil | integer(),
          timer_ref: nil | reference(),
          board: [Square.t()]
        }

  # 30 Minutes of inactivity ends the game
  @inactivity_timeout 1000 * 60 * 30

  @doc """
  Return an initialised GameState struct. Requires one player to start.
  """
  @spec new(game_code(), Player.t()) :: t()
  def new(game_code, %Player{} = player) do
    %GameState{code: game_code, players: [%Player{player | letter: "O"}]}
    |> reset_inactivity_timer()
  end

  @doc """
  Allow another player to join the game. Exactly 2 players are required to play.
  """
  @spec join_game(t(), Player.t()) :: {:ok, t()} | {:error, String.t()}
  def join_game(%GameState{players: []} = _state, %Player{}) do
    {:error, "Can only join a created game"}
  end

  def join_game(%GameState{players: [_p1, _p2]} = _state, %Player{} = _player) do
    {:error, "Only 2 players allowed"}
  end

  def join_game(%GameState{players: [p1]} = state, %Player{} = player) do
    player =
      if p1.letter == "O" do
        %Player{player | letter: "X"}
      else
        %Player{player | letter: "O"}
      end

    {:ok, %GameState{state | players: [p1, player]} |> reset_inactivity_timer()}
  end

  @spec start(t()) :: {:ok, t()} | {:error, String.t()}
  def start(%GameState{status: :playing}), do: {:error, "Game in play"}
  def start(%GameState{status: :done}), do: {:error, "Game is done"}

  def start(%GameState{status: :not_started, players: [_p1, _p2]} = state) do
    {:ok, %GameState{state | status: :playing, player_turn: "O"} |> reset_inactivity_timer()}
  end

  def start(%GameState{players: _players}), do: {:error, "Missing players"}

  defp reset_inactivity_timer(%GameState{} = state) do
    state
    |> cancel_timer()
    |> set_timer()
  end

  defp cancel_timer(%GameState{timer_ref: ref} = state) when is_reference(ref) do
    Process.cancel_timer(ref)
    %GameState{state | timer_ref: nil}
  end

  defp cancel_timer(%GameState{} = state), do: state

  defp set_timer(%GameState{} = state) do
    %GameState{
      state
      | timer_ref: Process.send_after(self(), :end_for_inactivity, @inactivity_timeout)
    }
  end
end
