defmodule BrainTrain.SpeedSort.GameState do
  alias BrainTrain.SpeedSort.Player
  alias BrainTrain.SpeedSort
  alias __MODULE__

  @type t :: %GameState{
          code: nil | String.t(),
          status: :not_started | :waiting | :playing | :done,
          players: map(),
          numbers: map(),
          elapsed_time: :float
        }

  @game_duration 60

  defstruct code: nil,
            players: %{},
            status: :not_started,
            numbers: %{},
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

  def join_game(%GameState{players: players}, %Player{}) when players == %{} do
    {:error, "Can only join a created game"}
  end

  def join_game(%GameState{players: players} = state, %Player{} = player) do
    {:ok, %GameState{state | players: Map.put(players, player.id, player)}}
  end

  def get_player(%GameState{players: players}, player_id) do
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

  def start(%GameState{status: :waiting, players: players} = state) do
    Process.send_after(self(), :update_timer, 1000)

    players =
      players
      |> Stream.map(&set_round_start_time(&1))
      |> Stream.map(&set_initial_numbers(&1, Map.get(state.numbers, 0)))
      |> Enum.into(%{})

    {:ok,
     %GameState{
       state
       | status: :playing,
         players: players
     }}
  end

  def start(%GameState{players: _player}), do: {:error, "Only one player"}

  defp set_round_start_time({id, player}) do
    {id, %Player{player | round_start_time: DateTime.utc_now()}}
  end

  defp set_initial_numbers({id, player}, numbers) do
    {id, %Player{player | numbers: numbers}}
  end

  def update_timer(%GameState{elapsed_time: elapsed_time} = state) do
    new_time = elapsed_time + 1

    if new_time < @game_duration do
      Process.send_after(self(), :update_timer, 1000)
      %GameState{state | elapsed_time: new_time}
    else
      %GameState{state | status: :done}
    end
  end

  def click(%GameState{} = state, %Player{} = player, index) do
    cond do
      player_completed_round?(player) ->
        round_complete(state, player, :correct)

      correct_index_clicked?(player, index) ->
        update_index(state, player)

      true ->
        round_complete(state, player, :incorrect)
    end
  end

  defp player_completed_round?(player), do: player.clicks == SpeedSort.list_length() - 1
  defp correct_index_clicked?(player, index), do: index == player.clicks

  def round_complete(
        %GameState{status: :playing} = state,
        %Player{} = player,
        result
      ) do
    existing_score = player.score
    current_round = player.round

    elapsed_time =
      DateTime.diff(
        DateTime.utc_now() |> Timex.set(microsecond: 0),
        player.round_start_time
      )

    new_score = SpeedSort.calculate_score(existing_score, elapsed_time, result)
    new_numbers = Map.get(state.numbers, current_round + 1)

    updated_player = %Player{
      player
      | round: current_round + 1,
        score: new_score,
        numbers: new_numbers,
        clicks: 0
    }

    updated_players = Map.put(state.players, player.id, updated_player)

    {:ok, %GameState{state | players: updated_players}}
  end

  def round_complete(
        %GameState{status: :done} = _state,
        %Player{} = _player,
        _result,
        _elapsed_time
      ) do
    {:error, "Game is over!"}
  end

  def update_index(state, player) do
    updated_player = %Player{player | clicks: player.clicks + 1}
    updated_players = Map.put(state.players, player.id, updated_player)

    {:ok, %GameState{state | players: updated_players}}
  end
end
