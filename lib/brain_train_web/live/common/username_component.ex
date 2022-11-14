defmodule BrainTrainWeb.Live.Common.UsernameComponent do
  use BrainTrainWeb, :live_component
  alias BrainTrainWeb.Presence

  def render(assigns) do
    ~H"""
    <div>
      <%= if is_nil(@name) do %>
        <div>
          <form phx-submit="set_name" phx-hook="SetSession" id="username" phx-target={@myself}>
            <label for="name" class="block text-sm font-medium text-gray-700 text-left">
              Your name
            </label>
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
      <% else %>
        <div>Let's go, <%= @name %>!</div>
      <% end %>
    </div>
    """
  end

  def handle_event("set_name", %{"name" => name}, socket) do
    Presence.join_session(name)
    {:noreply, assign(socket, name: name)}
  end
end
