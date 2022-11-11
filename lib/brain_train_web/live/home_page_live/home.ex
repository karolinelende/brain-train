defmodule BrainTrainWeb.Live.HomePageLive.Home do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Router.Helpers, as: Routes

  @high_score_length 10

  def mount(_params, session, socket) do
    if connected?(socket), do: Scores.subscribe()
    scores = Scores.top_scores(@high_score_length)

    socket =
      socket
      |> assign(scores: scores)
      |> assign(name: Map.get(session, "username"))

    {:ok, socket}
  end

  def handle_info({:score_saved, score}, socket) do
    socket =
      update(socket, :scores, fn scores ->
        Scores.maybe_append_top_score(scores, score, @high_score_length)
      end)

    {:noreply, socket}
  end

  def handle_event("set_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name: name)}
  end
end
