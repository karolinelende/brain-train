defmodule BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents do
  use BrainTrainWeb, :component

  def start_game(assigns) do
    ~H"""
    <button
      class="font-medium bg-gray-800 text-2xl rounded-lg py-4 px-4 text-white hover:bg-pink-800"
      phx-click="start_game"
    >
      Start game
    </button>
    """
  end

  def playing_game(assigns) do
    ~H"""
    <div>
      <div class="py-4">The numbers are:</div>
      <div class="grid grid-cols-3 gap-6">
        <%= for {number, index} <- @numbers do %>
          <%= if @clicks > index do %>
            <div class="w-16 h-16"></div>
          <% else %>
            <div>
              <button
                class="font-medium bg-red-600 w-16 h-16 text-2xl rounded-lg text-white"
                phx-click="rank-number"
                phx-value-index={index}
              >
                <%= number %>
              </button>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>

    <div class="py-8">The time is: <%= @now %></div>
    """
  end

  def ended_game(assigns) do
    ~H"""
    <div>Game ended :(</div>
    """
  end
end
