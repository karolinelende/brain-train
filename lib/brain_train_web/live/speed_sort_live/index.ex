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

  def handle_event("rank-number", %{"number" => number}, socket) do
    Process.send_after(self(), :clear_flash, 1500)

    socket =
      case SpeedSort.check_next_in_list(socket.assigns.numbers, String.to_integer(number)) do
        {:ok, message} ->
          socket
          |> put_flash(:info, message)
          |> assign(score: socket.assigns.score + 10)
          |> assign(numbers: SpeedSort.generate_list_of_numbers())

        {:error, message} ->
          socket
          |> put_flash(:error, message)
          |> assign(score: socket.assigns.score - 10)
          |> assign(numbers: SpeedSort.generate_list_of_numbers())

        new_numbers ->
          socket
          |> assign(numbers: new_numbers)
      end

    {:noreply, socket}
  end
end
