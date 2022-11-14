defmodule BrainTrainWeb.Live.TicTacToe.TicTacToeComponents do
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

    <form phx-submit="join_game">
      <label for="code" class="block text-sm font-medium text-gray-700 text-left mt-8">
        Game code (leave empty to start new game)
      </label>
      <div class="flex justify-between items-center">
        <div class="relative mt-1 w-full rounded-md mr-2">
          <input
            type="text"
            name="code"
            id="code"
            class="rounded-md w-full border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            value={@code}
          />
        </div>
        <button
          type="submit"
          class="p-2 mt-1 bg-gray-800 w-1/2 rounded-lg text-white hover:bg-pink-800 sm:text-sm"
        >
          Join game
        </button>
      </div>
    </form>

    <LiveComponents.score_table scores={@scores} all_games={false} />
    """
  end

  def playing_game(assigns) do
    ~H"""
    <div>
      Playing the game
    </div>
    """
  end
end
