defmodule BrainTrain.SpeedSort.GameState do
  alias BrainTrain.SpeedSort.Player
  alias BrainTrain.SpeedSort
  alias __MODULE__

  @type t :: %GameState{
          code: nil | String.t(),
          status: :not_started | :waiting | :playing | :done,
          players: map(),
          numbers: list(:integer),
          elapsed_time: :float
        }

  @game_duration 5

  defstruct code: nil,
            players: %{},
            status: :not_started,
            numbers: [],
            elapsed_time: 0

  def game_duration, do: @game_duration

  def new(game_code, %Player{} = player) do
    %GameState{
      code: game_code,
      players: %{player.id => player},
      status: :waiting,
      numbers: SpeedSort.generate_for_multi(),
      elapsed_time: 0
    }
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
    Process.send_after(self(), :update_timer, 1000)

    {:ok,
     %GameState{
       state
       | status: :playing
     }}
  end

  def start(%GameState{players: _player}), do: {:error, "Only one player"}

  def update_timer(%GameState{elapsed_time: elapsed_time} = state) do
    new_time = elapsed_time + 1

    if new_time < @game_duration do
      Process.send_after(self(), :update_timer, 1000)
      %GameState{state | elapsed_time: new_time}
    else
      %GameState{state | status: :done}
    end
  end
end
