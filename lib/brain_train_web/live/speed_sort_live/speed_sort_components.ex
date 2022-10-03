defmodule BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents do
  use BrainTrainWeb, :component

  def start_game(assigns) do
    ~H"""
    <%= if @message do %>
      <div class="font-medium bg-gray-200 text-2xl rounded-full py-4 px-4 m-8 text-white">
        <%= @message %>
      </div>
    <% end %>

    <button
      class="font-medium bg-gray-800 text-2xl rounded-lg py-4 px-4 text-white hover:bg-pink-800"
      phx-click="start_game"
    >
      Start game
    </button>

    <%= if @score do %>
      <div class="font-medium bg-green-400 text-2xl rounded-full py-4 px-4 m-8 text-white">
        Your score: <%= @score %>
      </div>
    <% end %>
    """
  end

  def playing_game(assigns) do
    ~H"""
    <div>
      <div class="py-4 my-8 px-4 bg-pink-500 rounded-full font-medium text-white">
        Rank the numbers from smallest to largest
      </div>

      <div class="font-medium bg-green-400 text-2xl rounded-full py-4 px-4 m-8 text-white">
        Your score: <%= @score %>
      </div>

      <div class="grid grid-cols-3 gap-12 p-8 rounded-lg bg-blue-100">
        <%= for {number, index} <- @numbers do %>
          <%= if @clicks > index do %>
            <div class="w-16 h-16"></div>
          <% else %>
            <div>
              <button
                class="font-medium bg-blue-600 w-16 h-16 text-2xl rounded-lg text-white"
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

    <div class="py-4 my-8 flex items-center justify-center bg-pink-200 rounded-full">
      <div class="px-1">Time remaining:</div>
      <div class="animate-ping w-8 px-2 text-center"><%= @remaining_time %></div>
      <div class="px-1">seconds</div>
    </div>
    """
  end

  def ended_game(assigns) do
    ~H"""
    <div>Game ended :(</div>
    """
  end
end
