defmodule BrainTrainWeb.Live.SpeedSortLive.Index do
  use Phoenix.LiveView, layout: {BrainTrainWeb.LayoutView, "live.html"}
  alias BrainTrain.SpeedSort
  alias BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update_now, 1000)

    numbers = SpeedSort.generate_list_of_numbers()

    socket =
      socket
      |> assign(numbers: numbers)
      |> assign(play: false)
      |> assign(now: DateTime.utc_now())
      |> assign(clicks: 0)

    {:ok, socket}
  end

  def handle_info(:update_now, socket) do
    Process.send_after(self(), :update_now, 1000)
    socket = assign(socket, :now, DateTime.utc_now() |> Timex.set(microsecond: 0))
    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("start_game", _, socket) do
    socket = assign(socket, play: true, score: 0)

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
