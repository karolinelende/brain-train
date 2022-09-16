defmodule BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents do
  use BrainTrainWeb, :component

  def start_game(assigns) do
    ~H"""
    <button phx-click="start_game"> Start game </button>

    """
  end

  def playing_game(assigns) do
    ~H"""
    <div> The numbers are:
    <%= for number <- @numbers do %>
    <button phx-click="rank-number" phx-value-number={number}> <%= number %> </button>
    <% end %>
    </div>

    <div> The time is:
    <%= @now %>
    </div>
    """
  end

  def ended_game(assigns) do
    ~H"""
      <div> Game ended :( </div>
    """
  end
end
