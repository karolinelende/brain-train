defmodule BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents do
  use BrainTrainWeb, :component
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Live.Common.UsernameComponent

  def start_game(assigns) do
    ~H"""
    <%= if @message do %>
      <div class="font-medium bg-gray-200 text-2xl rounded-lg py-4 px-4 m-4 text-pink-800 animate-pulse">
        <%= @message %>
      </div>
    <% end %>

    <%= if @score do %>
      <div class="font-medium bg-emerald-700 text-2xl rounded-lg py-4 px-4 mt-8 text-white">
        Your score: <%= @score %>
      </div>
    <% else %>
      <%= live_component(UsernameComponent, id: 1, name: @name) %>
    <% end %>

    <button
      class="font-medium bg-gray-800 text-2xl rounded-lg py-4 mt-12 px-4 text-white hover:bg-pink-800"
      phx-click="start_game"
    >
      <%= if @score do %>
        Play again
      <% else %>
        Start game
      <% end %>
    </button>

    <LiveComponents.score_table scores={@scores} all_games={false} />
    """
  end

  def playing_game(assigns) do
    ~H"""
    <div>
      <div class="py-4 my-8 flex items-center justify-center bg-emerald-50 rounded-lg">
        <div class="px-1">Time remaining:</div>
        <div class="animate-ping w-8 px-2 text-center"><%= @remaining_time %></div>
        <div class="px-1">seconds</div>
      </div>

      <div class="grid grid-cols-3 gap-12 p-8 rounded-lg bg-pink-50">
        <%= for {number, index} <- @numbers do %>
          <%= if @clicks > index do %>
            <div class="w-16 h-16"></div>
          <% else %>
            <div>
              <button
                class="font-medium bg-pink-800 w-16 h-16 text-2xl rounded-lg text-white"
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

    <div class="font-medium bg-emerald-700 text-2xl rounded-lg py-4 px-4 m-8 text-white">
      Your score: <%= @score %>
    </div>
    """
  end
end
