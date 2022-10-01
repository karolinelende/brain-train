defmodule BrainTrainWeb.Live.SpeedSortLive.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.SpeedSort
  alias BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents

  def mount(_params, _session, socket) do
    numbers = SpeedSort.generate_list_of_numbers()

    socket =
      socket
      |> assign(numbers: numbers)
      |> assign(play: false)
      |> assign(clicks: 0)

    {:ok, socket}
  end

  def handle_info(:update_timer, socket) do
    Process.send_after(self(), :update_timer, 1000)

    socket =
      assign(
        socket,
        :elapsed_time,
        DateTime.diff(DateTime.utc_now() |> Timex.set(microsecond: 0), socket.assigns.start_time)
      )

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("start_game", _, socket) do
    Process.send_after(self(), :update_timer, 1000)

    socket =
      socket
      |> assign(play: true)
      |> assign(score: 0)
      |> assign(start_time: DateTime.utc_now())
      |> assign(elapsed_time: 0)

    {:noreply, socket}
  end

  def handle_event(
        "rank-number",
        %{"index" => index},
        %{assigns: %{clicks: clicks, score: score}} = socket
      ) do
    socket =
      cond do
        clicks == SpeedSort.list_length() - 1 ->
          Process.send_after(self(), :clear_flash, 1000)

          socket
          |> put_flash(:info, "Good job!")
          |> assign(score: score + 10)
          |> assign(numbers: SpeedSort.generate_list_of_numbers())
          |> assign(clicks: 0)

        String.to_integer(index) == clicks ->
          socket
          |> assign(clicks: clicks + 1)

        true ->
          Process.send_after(self(), :clear_flash, 1000)

          socket
          |> put_flash(:error, "Wrong number!")
          |> assign(score: score - 10)
          |> assign(numbers: SpeedSort.generate_list_of_numbers())
          |> assign(clicks: 0)
      end

    {:noreply, socket}
  end
end
