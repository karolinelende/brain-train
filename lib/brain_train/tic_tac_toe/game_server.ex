defmodule BrainTrain.TicTacToe.GameServer do
  @moduledoc """
  A GenServer that manages and models the state for a specific game instance.
  """
  use GenServer
  require Logger

  alias __MODULE__
  alias BrainTrain.TicTacToe.GameState
  alias Phoenix.PubSub

  def child_spec(opts) do
    name = Keyword.get(opts, :name, GameServer)
    player = Keyword.fetch!(opts, :player)

    %{
      id: "#{GameServer}_#{name}",
      start: {GameServer, :start_link, [name, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(name, player) do
    case GenServer.start_link(GameServer, %{player: player, code: name}, name: via_tuple(name)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started GameServer #{inspect(name)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  def generate_game_code() do
    codes = Enum.map(1..3, fn _ -> do_generate_code() end)

    case Enum.find(codes, &(!GameServer.server_found?(&1))) do
      nil ->
        {:error, "Didn't find unused code, try again later"}

      code ->
        {:ok, code}
    end
  end

  defp do_generate_code() do
    range = ?A..?Z

    1..4
    |> Enum.map(fn _ -> [Enum.random(range)] |> List.to_string() end)
    |> Enum.join("")
  end

  def start_or_join(game_code, player) do
    Horde.DynamicSupervisor.start_child(
      BrainTrain.DistributedSupervisor,
      {GameServer, [name: game_code, player: player]}
    )

    case Horde.DynamicSupervisor.start_child(
           BrainTrain.DistributedSupervisor,
           {GameServer, [name: game_code, player: player]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started game server #{inspect(game_code)}")
        {:ok, :started}

      :ignore ->
        Logger.info("Game server #{inspect(game_code)} already running. Joining")

        case join_game(game_code, player) do
          :ok -> {:ok, :joined}
          {:error, _reason} = error -> error
        end
    end
  end

  def join_game(game_code, player) do
    GenServer.call(via_tuple(game_code), {:join_game, player})
  end

  @impl true
  def init(%{player: player, code: code}) do
    {:ok, GameState.new(code, player)}
  end

  @impl true
  def handle_call({:join_game, player}, _from, %GameState{} = state) do
    with {:ok, new_state} <- GameState.join_game(state, player),
         {:ok, started} <- GameState.start(new_state) do
      broadcast_game_state(started)
      {:reply, :ok, started}
    else
      {:error, reason} = error ->
        Logger.error("Failed to join and start game. Error: #{inspect(reason)}")
        {:reply, error, state}
    end
  end

  def broadcast_game_state(%GameState{} = state) do
    PubSub.broadcast(BrainTrain.PubSub, "game:#{state.code}", {:game_state, state})
  end

  def via_tuple(game_code),
    do: {:via, Horde.Registry, {BrainTrain.GameRegistry, game_code}}

  def server_found?(game_code) do
    case Horde.Registry.lookup(BrainTrain.GameRegistry, game_code) do
      [] -> false
      [{pid, _} | _] when is_pid(pid) -> true
    end
  end
end