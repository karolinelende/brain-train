defmodule BrainTrainWeb.Live.Common.LiveComponents do
  use BrainTrainWeb, :component

  def score_table(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8 mt-16">
      <h2 class="font-medium text-2xl text-gray-800">🏆 High Scores 🏆</h2>
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
                      Rank
                    </th>
                    <th
                      scope="col"
                      class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                    >
                      Name
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                    >
                      Score
                    </th>
                    <%= if @all_games do %>
                      <th
                        scope="col"
                        class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                      >
                        Game
                      </th>
                    <% end %>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                  <%= for {score, index} <- Enum.with_index(@scores) do %>
                    <tr>
                      <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                        <%= index + 1 %>
                      </td>
                      <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                        <%= score.name %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= score.score %>
                      </td>
                      <%= if @all_games do %>
                        <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          <%= score.game %>
                        </td>
                      <% end %>
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

  def username_input(assigns) do
    ~H"""
    <div>
      <form phx-submit="set_name" phx-hook="SetSession" id="username">
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
end
