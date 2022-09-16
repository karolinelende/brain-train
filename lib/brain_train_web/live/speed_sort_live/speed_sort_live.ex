defmodule BrainTrainWeb.Live.SpeedSortLive.Index do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 30000)
    {:ok, assign(socket, temperature: 20)}
  end

  # def handle_info(:update, socket) do
  #   Process.send_after(self(), :update, 30000)
  #   {:ok, temperature} = Thermostat.get_reading(socket.assigns.user_id)
  #   {:noreply, assign(socket, :temperature, temperature)}
  # end

  def render(assigns) do
    ~H"""
    <%= @temperature %>
    """
  end
end
