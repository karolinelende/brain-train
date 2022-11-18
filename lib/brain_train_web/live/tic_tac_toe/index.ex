defmodule BrainTrainWeb.Live.TicTacToe.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.TicTacToe.TicTacToeComponents
  alias BrainTrain.TicTacToe.GameServer
  alias BrainTrainWeb.Live.TicTacToe.GameStarter
  alias BrainTrain.TicTacToe.Player

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
      |> assign(code: nil)
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
      socket = socket |> assign(play: true, code: game_code, player: player.id)

      {:noreply, socket}
    else
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end
end
