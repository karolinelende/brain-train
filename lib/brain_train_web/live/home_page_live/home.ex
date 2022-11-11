defmodule BrainTrainWeb.Live.HomePageLive.Home do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    if connected?(socket), do: Scores.subscribe()
    scores = Scores.get_scores_for_game("speed_sort")

    socket =
      socket
      |> assign(scores: scores)

    {:ok, socket}
  end
end
