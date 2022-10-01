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
      <div class="py-4 my-8 px-4 bg-pink-500 rounded-full font-medium text-white">
        Rank the numbers from smallest to largest
      </div>
      <div class="grid grid-cols-3 gap-12">
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
      <div class="px-1">Elapsed time:</div>
      <div class="animate-ping w-8 px-2 text-center"><%= @elapsed_time %></div>
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
