defmodule BrainTrainWeb.Live.SpeedSortMulti.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, :live}
  alias BrainTrain.{Scores, SpeedSort}
  alias BrainTrain.SpeedSort.{GameServer, GameState, Player}
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.SpeedSortMulti.{SpeedSortGameStarter, SpeedSortMultiComponents}

  @game_title SpeedSort.db_name()

  def mount(_params, session, socket) do
    if connected?(socket) do
      Scores.subscribe()
      Presence.join_session(Map.get(session, "username"))
    end

    scores = Scores.get_scores_for_game(@game_title)

    socket =
      socket
      |> assign(game: %GameState{})
      |> assign(message: nil)
      |> assign(game_code: nil)
      |> assign(name: Map.get(session, "username"))
      |> assign(changeset: SpeedSortGameStarter.insert_changeset(%{}))
      |> assign(scores: scores)

    {:ok, socket}
  end

  def handle_event("join_game", params, socket) do
    params = Map.merge(params, %{"name" => socket.assigns.name})

    with {:ok, starter} <- SpeedSortGameStarter.create(params),
         {:ok, game_code} <- SpeedSortGameStarter.get_game_code(starter),
         {:ok, player} <- Player.create(%{name: socket.assigns.name}),
         {:ok, _} <- GameServer.start_or_join(game_code, player) do
      Phoenix.PubSub.subscribe(BrainTrain.PubSub, "game:#{game_code}")
      send(self(), :load_game_state)

      game = GameServer.get_current_game_state(game_code)

      socket =
        socket
        |> clear_flash()
        |> assign(
          game_code: game_code,
          player_id: player.id,
          player: player,
          game: game
        )

      {:noreply, socket}
    else
      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_event("start_game", _params, socket) do
    with :ok <- GameServer.start_game(socket.assigns.game_code) do
      {:noreply, socket}
    else
      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_event(
        "rank-number",
        %{"index" => index},
        %{assigns: %{player: player, game_code: game_code}} = socket
      ) do
    # TODO can return a message here to add to the flash
    GameServer.click(game_code, player.id, String.to_integer(index))

    {:noreply, socket}
  end

  def handle_info(:load_game_state, %{assigns: %{server_found: true}} = socket) do
    case GameServer.get_current_game_state(socket.assigns.game_code) do
      %GameState{} = game ->
        player = GameState.get_player(game, socket.assigns.player_id)
        {:noreply, assign(socket, server_found: true, game: game, player: player)}

      _ ->
        {:noreply, assign(socket, :server_found, false)}
    end
  end

  def handle_info(:load_game_state, socket) do
    Process.send_after(self(), :load_game_state, 500)
    {:noreply, assign(socket, :server_found, GameServer.server_found?(socket.assigns.game_code))}
  end

  def handle_info({:game_state, %GameState{} = state} = _event, socket) do
    player_id = socket.assigns.player_id
    {:ok, player} = GameState.find_player(state, player_id)

    new_player = get_new_player(socket.assigns.game, state)

    socket =
      socket
      |> clear_flash()
      |> assign(:game, state)
      |> assign(:player, player)
      |> push_event("bounce", %{id: "player-#{new_player}"})
      |> maybe_save_and_assign_scores(state, player)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:score_saved, score}, socket) do
    socket = update(socket, :scores, fn scores -> Scores.append_and_sort(scores, score) end)

    {:noreply, socket}
  end

  defp get_new_player(%{players: old_players}, %{players: new_players}) do
    if length(Enum.into(old_players, [])) == length(Enum.into(new_players, [])) do
      nil
    else
      %{added: added} = MapDiff.diff(old_players, new_players)
      [player] = Map.values(added)
      player.name
    end
  end

  defp get_new_player(_old_state, _new_stage), do: nil

  defp maybe_save_and_assign_scores(
         socket,
         %GameState{status: :done, players: players},
         player
       ) do
    %{name: player.name, score: player.score, game: @game_title}
    |> Scores.insert()

    this_game_scores = Enum.map(players, fn {_player_id, player} -> player end)

    winner_id =
      this_game_scores
      |> Enum.max_by(& &1.score)
      |> Map.get(:id)

    is_winner? = winner_id == player.id

    socket
    |> assign(this_game_scores: this_game_scores)
    |> assign(is_winner: is_winner?)
    |> add_confetti(is_winner?)
  end

  defp maybe_save_and_assign_scores(socket, _game_state, _player), do: socket

  defp add_confetti(socket, true), do: socket |> push_event("fire_confetti", %{id: "game-over"})
  defp add_confetti(socket, _), do: socket
end
