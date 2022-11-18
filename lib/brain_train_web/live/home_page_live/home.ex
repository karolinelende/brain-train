defmodule BrainTrainWeb.Live.HomePageLive.Home do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, :live}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Live.Common.UsernameComponent
  alias BrainTrainWeb.Router.Helpers, as: Routes
  alias BrainTrainWeb.Presence

  @high_score_length 10

  def mount(_params, session, socket) do
    if connected?(socket) do
      Scores.subscribe()
      Presence.join_session(Map.get(session, "username"))
      Phoenix.PubSub.subscribe(BrainTrain.PubSub, Presence.channel_name())
    end

    scores = Scores.top_scores(@high_score_length)

    socket =
      socket
      |> assign(scores: scores)
      |> assign(name: Map.get(session, "username"))
      |> assign(:users, %{})
      |> handle_joins(Presence.list(Presence.channel_name()))

    {:ok, socket}
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(
        socket,
        :users,
        Map.put(socket.assigns.users, user, meta) |> sort_users()
      )
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user) |> sort_users())
    end)
  end

  defp sort_users(users) do
    Enum.sort_by(users, fn {_id, user_map} ->
      user_map.name
    end)
    |> Enum.into(%{})
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {
      :noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  def handle_info({:score_saved, score}, socket) do
    socket =
      update(socket, :scores, fn scores ->
        Scores.maybe_append_top_score(scores, score, @high_score_length)
      end)

    {:noreply, socket}
  end
end
