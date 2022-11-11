defmodule BrainTrainWeb.Live.HomePageLive.Home do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.Scores
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Router.Helpers, as: Routes
  alias BrainTrainWeb.Presence

  @high_score_length 10
  @presence "users:presence"

  def mount(_params, session, socket) do
    if connected?(socket) do
      Scores.subscribe()

      user = Map.get(session, "username")
      join_session(user)

      Phoenix.PubSub.subscribe(BrainTrain.PubSub, @presence)
    end

    scores = Scores.top_scores(@high_score_length)

    socket =
      socket
      |> assign(scores: scores)
      |> assign(name: Map.get(session, "username"))
      |> assign(:users, %{})
      |> handle_joins(Presence.list(@presence))

    {:ok, socket}
  end

  defp join_session(nil), do: :ok

  defp join_session(user) do
    {:ok, _} =
      Presence.track(self(), @presence, get_temp_id(), %{
        name: user,
        joined_at: :os.system_time(:seconds)
      })
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

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

  def handle_event("set_name", %{"name" => name}, socket) do
    join_session(name)
    {:noreply, assign(socket, name: name)}
  end
end
