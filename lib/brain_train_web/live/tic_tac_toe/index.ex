defmodule BrainTrainWeb.Live.TicTacToe.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, :live}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.TicTacToe.{GameStarter, TicTacToeComponents}
  alias BrainTrain.TicTacToe.{GameServer, GameState, Player}

  @game_title "tic_tac_toe"

  def mount(_params, session, socket) do
    if connected?(socket) do
      Scores.subscribe()
      Presence.join_session(Map.get(session, "username"))
    end

    scores = Scores.get_scores_for_game(@game_title)

    socket =
      socket
      |> assign(play: false)
      |> assign(score: nil)
      |> assign(message: nil)
      |> assign(game_code: nil)
      |> assign(name: Map.get(session, "username"))
      |> assign(scores: scores)

    {:ok, socket}
  end

  def handle_event("join_game", params, socket) do
    params = Map.merge(params, %{"name" => socket.assigns.name})

    with {:ok, starter} <- GameStarter.create(params),
         {:ok, game_code} <- GameStarter.get_game_code(starter),
         {:ok, player} <- Player.create(%{name: socket.assigns.name}),
         {:ok, _} <- GameServer.start_or_join(game_code, player) do
      Phoenix.PubSub.subscribe(BrainTrain.PubSub, "game:#{game_code}")
      send(self(), :load_game_state)

      socket =
        socket
        |> assign(
          play: true,
          game_code: game_code,
          player_id: player.id,
          player: nil,
          game: %GameState{}
        )

      {:noreply, socket}
    else
      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_event(
        "move",
        %{"square" => square},
        %{assigns: %{game_code: code, player: player}} = socket
      ) do
    case GameServer.move(code, player.id, String.to_atom(square)) do
      :ok ->
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("restart", _params, %{assigns: %{game_code: code}} = socket) do
    case GameServer.restart(code) do
      :ok ->
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
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
    updated_socket =
      socket
      |> clear_flash()
      |> assign(:game, state)

    {:noreply, updated_socket}
  end
end
