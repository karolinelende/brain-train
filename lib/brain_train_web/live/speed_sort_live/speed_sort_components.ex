defmodule BrainTrainWeb.Live.SpeedSortLive.SpeedSortComponents do
  use BrainTrainWeb, :component

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
      <%= if is_nil(@name) do %>
        <.username_input name={@name} />
      <% else %>
        <div>Let's go, <%= @name %>!</div>
      <% end %>
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

    <.score_table scores={@scores} />
    """
  end

  defp username_input(assigns) do
    ~H"""
    <div>
      <form phx-submit="set_name">
        <label for="name" class="block text-sm font-medium text-gray-700 text-left">Your name</label>
        <div class="flex justify-between items-center">
          <div class="relative mt-1 w-full rounded-md mr-2">
            <input
              type="text"
              name="name"
              id="name"
              class="rounded-md w-full border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              value={@name}
            />
          </div>
          <button
            type="submit"
            class="p-2 mt-1 bg-gray-800 rounded-lg text-white hover:bg-pink-800 sm:text-sm"
          >
            Save
          </button>
        </div>
      </form>
    </div>
    """
  end

  defp score_table(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="mt-8 flex flex-col">
        <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
            <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <th
                      scope="col"
                      class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                    >
                      Name
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Score
                    </th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                  <%= for score <- @scores do %>
                    <tr>
                      <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                        <%= score.name %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= score.score %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
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
