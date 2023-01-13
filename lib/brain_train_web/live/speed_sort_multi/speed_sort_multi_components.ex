defmodule BrainTrainWeb.Live.SpeedSortMulti.SpeedSortMultiComponents do
  use BrainTrainWeb, :component
  alias BrainTrainWeb.Live.Common.UsernameComponent

  def start_game(assigns) do
    ~H"""
    <%= if @message do %>
      <div class="font-medium bg-gray-200 text-2xl rounded-lg py-4 px-4 m-4 text-pink-800 animate-pulse">
        <%= @message %>
      </div>
    <% end %>

    <%= live_component(UsernameComponent, id: 1, name: @name) %>

    <form phx-submit="join_game">
      <label for="game_code" class="block text-sm font-medium text-gray-700 text-left mt-8">
        Game code (leave empty to start new game)
      </label>
      <div class="flex justify-between items-center">
        <div class="relative mt-1 w-full rounded-md mr-2">
          <input
            type="text"
            name="game_code"
            id="game_code"
            class="rounded-md w-full border-gray-300 shadow-sm focus:border-pink-500 focus:ring-pink-500 sm:text-sm"
            value={@game_code}
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
    """
  end

  def playing_game(assigns) do
    ~H"""
    <div class="font-medium bg-emerald-700 text-2xl rounded-lg py-4 px-4 m-8 text-white">
      Playing game
    </div>
    """
  end
end