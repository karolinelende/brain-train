defmodule BrainTrainWeb.Live.SpeedSortMulti.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, :live}
  alias BrainTrain.SpeedSort
  alias BrainTrain.SpeedSort.{GameServer, GameState, Player}
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.SpeedSortMulti.{SpeedSortGameStarter, SpeedSortMultiComponents}

  @game_title SpeedSort.db_name()

  def mount(_params, session, socket) do
    if connected?(socket) do
      Presence.join_session(Map.get(session, "username"))
    end

    socket =
      socket
      |> assign(game: %GameState{})
      |> assign(message: nil)
      |> assign(game_code: nil)
      |> assign(name: Map.get(session, "username"))
      |> assign(changeset: SpeedSortGameStarter.insert_changeset(%{}))

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

    updated_socket =
      socket
      |> clear_flash()
      |> assign(:game, state)
      |> assign(:player, player)

    {:noreply, updated_socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
