defmodule BrainTrainWeb.Live.SpeedSortMulti.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, :live}
  alias BrainTrain.SpeedSort
  alias BrainTrainWeb.Presence
  alias BrainTrainWeb.Live.SpeedSortMulti.SpeedSortMultiComponents

  @game_duration 10
  @game_title SpeedSort.db_name()

  def mount(_params, session, socket) do
    if connected?(socket) do
      Presence.join_session(Map.get(session, "username"))
    end

    socket =
      socket
      |> assign(play: false)
      |> assign(message: nil)
      |> assign(game_code: nil)
      |> assign(name: Map.get(session, "username"))

    {:ok, socket}
  end
end
