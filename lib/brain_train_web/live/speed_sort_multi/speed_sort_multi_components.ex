defmodule BrainTrainWeb.Live.SpeedSortMulti.SpeedSortMultiComponents do
  use BrainTrainWeb, :component
  alias BrainTrainWeb.Live.Common.UsernameComponent
  alias BrainTrain.SpeedSort.GameState

  def home(assigns) do
    ~H"""
    <%= if @message do %>
      <div class="font-medium bg-gray-200 text-2xl rounded-lg py-4 px-4 m-4 text-pink-800 animate-pulse">
        <%= @message %>
      </div>
    <% end %>

    <%= live_component(UsernameComponent, id: 1, name: @name) %>

    <.form :let={f} for={@changeset} phx-submit="join_game">
      <div>
        <%= error_tag(f, :name) %>
      </div>
      <label for="game_code" class="block text-sm font-medium text-gray-700 text-left mt-8">
        Game code (leave empty to start new game)
      </label>
      <div class="flex justify-between items-baseline">
        <div class="relative mt-1 w-full rounded-md mr-2">
          <input
            type="text"
            name="game_code"
            id="game_code"
            class="rounded-md w-full border-gray-300 shadow-sm focus:border-pink-500 focus:ring-pink-500 sm:text-sm"
            value={@game_code}
          />
          <div>
            <%= error_tag(f, :game_code) %>
          </div>
        </div>
        <button
          type="submit"
          class="p-2 mt-1 bg-gray-800 w-1/2 rounded-lg text-white hover:bg-pink-800 sm:text-sm"
        >
          Join game
        </button>
      </div>
    </.form>
    """
  end

  def waiting_room(assigns) do
    ~H"""
    <p class="mt-8 text-center font-medium">
      Tell friends to use this game code to join you!
    </p>
    <div class="mt-2 text-8xl text-pink-800 text-center font-semibold">
      <%= @game_code %>
    </div>

    <div>
      Waiting for others to join...
      <div>
        <h2 class="font-medium text-2xl text-pink-800 py-4">Players</h2>
        <ul>
          <%= for {_id, %{name: name}} <- @game.players do %>
            <li class="py-2">
              <%= name %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    <button
      phx-click="start_game"
      class="p-2 mt-1 bg-gray-800 w-1/2 rounded-lg text-white hover:bg-pink-800 sm:text-sm"
    >
      Start game
    </button>
    """
  end

  def board(assigns) do
    ~H"""
    <div>
      <div class="py-4 my-8 flex items-center justify-center bg-emerald-50 rounded-lg">
        <div class="px-1">Time remaining:</div>
        <div class="animate-ping w-8 px-2 text-center">
          <%= GameState.game_duration() - @game.elapsed_time %>
        </div>
        <div class="px-1">seconds</div>
      </div>

      <div class="grid grid-cols-3 gap-12 p-8 rounded-lg bg-pink-50">
        <%= for {number, index} <- @player.numbers do %>
          <%= if @player.clicks > index do %>
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
    """
  end

  def game_over(assigns) do
    ~H"""
    <div>Game over!!!</div>
    """
  end
end
