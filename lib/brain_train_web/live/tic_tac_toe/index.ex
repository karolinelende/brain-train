defmodule BrainTrainWeb.Live.TicTacToe.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.TicTacToe.TicTacToeComponents

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

  def handle_event("join_game", %{"code" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("join_game", %{"code" => code}, socket) do
    IO.inspect(code)
    {:noreply, socket}
  end
end
