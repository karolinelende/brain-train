defmodule BrainTrainWeb.Live.SpeedSortLive.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.SpeedSort
  alias BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents
  alias BrainTrain.Scores

  @game_duration 10
  @game_title SpeedSort.db_name()

  def mount(_params, _session, socket) do
    if connected?(socket), do: Scores.subscribe()
    scores = Scores.get_scores_for_game(@game_title)

    socket =
      socket
      |> assign(play: false)
      |> assign(score: nil)
      |> assign(message: nil)
      |> assign(name: nil)
      |> assign(scores: scores)

    {:ok, socket}
  end

  def handle_info(:update_timer, socket) do
    remaining_time =
      @game_duration -
        DateTime.diff(
          DateTime.utc_now() |> Timex.set(microsecond: 0),
          socket.assigns.game_start_time
        )

    socket =
      if remaining_time > 0 do
        Process.send_after(self(), :update_timer, 1000)
        assign(socket, :remaining_time, remaining_time)
      else
        complete_game(socket)
      end

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:score_saved, score}, socket) do
    socket = update(socket, :scores, fn scores -> Scores.append_and_sort(scores, score) end)

    {:noreply, socket}
  end

  defp complete_game(%{assigns: %{name: name, score: score}} = socket) do
    Process.send_after(self(), :clear_flash, 1000)

    %{name: name, score: score, game: @game_title}
    |> Scores.insert()

    socket
    |> assign(message: "Game over")
    |> assign(play: false)
    |> assign(clicks: 0)
  end

  def handle_event("start_game", _, socket) do
    Process.send_after(self(), :update_timer, 1000)

    numbers = SpeedSort.generate_list_of_numbers()

    socket =
      socket
      |> assign(numbers: numbers)
      |> assign(clicks: 0)
      |> assign(play: true)
      |> assign(score: 0)
      |> assign(game_start_time: DateTime.utc_now())
      |> assign(round_start_time: DateTime.utc_now())
      |> assign(remaining_time: @game_duration)

    {:noreply, socket}
  end

  def handle_event("set_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name: name)}
  end

  def handle_event(
        "rank-number",
        %{"index" => index},
        %{assigns: %{clicks: clicks, score: score}} = socket
      ) do
    socket =
      cond do
        clicks == SpeedSort.list_length() - 1 ->
          completed_round(socket, score)

        String.to_integer(index) == clicks ->
          socket
          |> assign(clicks: clicks + 1)

        true ->
          failed_round(socket, score)
      end

    {:noreply, socket}
  end

  defp completed_round(socket, score) do
    Process.send_after(self(), :clear_flash, 1000)

    elapsed_time =
      DateTime.diff(
        DateTime.utc_now() |> Timex.set(microsecond: 0),
        socket.assigns.round_start_time
      )

    socket
    |> put_flash(:info, "Good job!")
    |> assign(score: round(score + 10 + 20 / elapsed_time))
    |> assign(numbers: SpeedSort.generate_list_of_numbers())
    |> assign(round_start_time: DateTime.utc_now())
    |> assign(clicks: 0)
  end

  defp failed_round(socket, score) do
    Process.send_after(self(), :clear_flash, 1000)

    socket
    |> put_flash(:error, "Wrong number!")
    |> assign(score: score - 5)
    |> assign(numbers: SpeedSort.generate_list_of_numbers())
    |> assign(clicks: 0)
  end
end
