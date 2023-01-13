defmodule BrainTrain.SpeedSort.GameState do
  alias BrainTrain.SpeedSort.Player
  alias BrainTrain.SpeedSort
  alias __MODULE__

  @type t :: %GameState{
          code: nil | String.t(),
          status: :not_started | :waiting | :playing | :done,
          players: map(),
          numbers: list(:integer)
        }

  defstruct code: nil,
            players: %{},
            status: :not_started,
            numbers: []

  def new(game_code, %Player{} = player) do
    %GameState{code: game_code, players: %{player.id => player}, status: :waiting}
  end

  def join_game(%GameState{players: players} = _state, %Player{}) when players == %{} do
    {:error, "Can only join a created game"}
  end

  def join_game(%GameState{players: players} = state, %Player{} = player) do
    {:ok, %GameState{state | players: Map.put(players, player.id, player)}}
  end

  def get_player(%GameState{players: players} = _state, player_id) do
    Map.get(players, player_id)
  end

  def find_player(%GameState{} = state, player_id) do
    case get_player(state, player_id) do
      nil ->
        {:error, "Player not found"}

      %Player{} = player ->
        {:ok, player}
    end
  end

  def start(%GameState{status: :playing}), do: {:error, "Game in play"}
  def start(%GameState{status: :done}), do: {:error, "Game is done"}
  def start(%GameState{status: :not_started}), do: {:error, "No players have joined"}

  def start(%GameState{status: :waiting, players: _players} = state) do
    {:ok, %GameState{state | status: :playing, numbers: SpeedSort.generate_for_multi()}}
  end

  def start(%GameState{players: _player}), do: {:error, "Only one player"}

  # @spec result(t()) :: :playing | :draw | Player.t()
  # def result(%GameState{players: players} = state) do
  #   player_1_won =
  #     case check_for_player_win(state, p1) do
  #       :not_found -> false
  #       [_, _, _] -> true
  #     end

  #   player_2_won =
  #     case check_for_player_win(state, p2) do
  #       :not_found -> false
  #       [_, _, _] -> true
  #     end

  #   cond do
  #     player_1_won -> p1
  #     player_2_won -> p2
  #     valid_moves(state) == [] -> :draw
  #     true -> :playing
  #   end
  # end

  def round_complete({:ok, %GameState{} = state}, %Player{} = player, result, elapsed_time) do
    round_complete(state, player, result, elapsed_time)
  end

  def round_complete(
        %GameState{status: :playing} = state,
        %Player{} = player,
        result,
        elapsed_time
      ) do
    existing_score = player.score
    current_round = player.round
    new_score = SpeedSort.calculate_score(existing_score, elapsed_time, result)

    updated_player = %Player{player | round: current_round + 1, score: new_score}
    updated_players = Map.put(state.players, player.id, updated_player)

    {:ok, %GameState{state | players: updated_players}}
  end

  def round_complete(
        %GameState{status: :not_started} = _state,
        %Player{} = _player,
        _result,
        _elapsed_time
      ) do
    {:error, "Game hasn't started yet!"}
  end

  def round_complete(
        %GameState{status: :done} = _state,
        %Player{} = _player,
        _result,
        _elapsed_time
      ) do
    {:error, "Game is over!"}
  end

  def restart(%GameState{} = state) do
    {:ok, %GameState{state | status: :playing, numbers: SpeedSort.generate_for_multi()}}
  end

  # defp check_for_done({:ok, %GameState{} = state}) do
  #   case result(state) do
  #     :playing ->
  #       {:ok, state}

  #     _game_done ->
  #       {:ok, %GameState{state | status: :done}}
  #   end
  # end

  # defp check_for_done({:error, _reason} = error), do: error
end
