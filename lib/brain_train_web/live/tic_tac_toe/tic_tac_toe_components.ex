defmodule BrainTrainWeb.Live.TicTacToe.TicTacToeComponents do
  use BrainTrainWeb, :component
  use Phoenix.HTML
  alias BrainTrainWeb.Live.Common.LiveComponents
  alias BrainTrainWeb.Live.Common.UsernameComponent
  alias BrainTrain.TicTacToe.{GameState, Player, Square}

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

    <LiveComponents.score_table scores={@scores} all_games={false} />
    """
  end

  def playing_game(assigns) do
    ~H"""
    <%= if @game.status == :not_started do %>
      <p class="mt-8 text-center font-medium">
        Tell a friend to use this game code to join you!
      </p>
      <div class="mt-2 text-8xl text-pink-800 text-center font-semibold">
        <%= @game_code %>
      </div>
    <% else %>
      <%= if @player do %>
        <div class="mb-4 text-lg leading-6 font-medium text-gray-900 text-center">
          Player: <span class="font-semibold"><%= @player.name %></span>
        </div>
      <% end %>

      <div class="p-4 sm:p-8 border border-gray-200 rounded-lg bg-gray-100">
        <ul class="mb-4 grid grid-cols-1 gap-5 sm:gap-6 sm:grid-cols-2 lg:grid-cols-2">
          <%= for player <- @game.players do %>
            <li class="col-span-1 flex rounded-md">
              <div class={"flex-shrink-0 flex items-center justify-center w-16 #{player_tile_color(@game, player, @player)} text-white text-sm font-medium rounded-l-md"}>
                <%= player.letter %>
              </div>
              <div class="flex-1 flex items-center justify-between border-t border-r border-b border-gray-200 bg-white rounded-r-md truncate">
                <div class="flex-1 px-4 py-2 text-sm truncate">
                  <p class="text-gray-900 font-medium hover:text-gray-600"><%= player.name %></p>
                </div>
              </div>
            </li>
          <% end %>
        </ul>

        <div class="text-2xl sm:text-8xl bg-gray-800 text-center ">
          <%= for row <- [1, 2, 3] do %>
            <div class="mt-2 grid gap-y-1 gap-x-1 grid-cols-3">
              <%= for column <- [1, 2, 3] do %>
                <div class="flex bg-gray-100">
                  <%= square(@player, @game, square_id(row, column),
                    phx_click: "move",
                    phx_value_square: square_id(row, column)
                  ) %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    <% end %>

    <div class="m-4 sm:m-8 text-3xl sm:text-6xl text-center text-green-700">
      <%= result(@game) %>
    </div>

    <%= if @game.status == :done do %>
      <div class="text-center">
        <button
          phx-click="restart"
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-pink-700 hover:bg-pink-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Restart Game
        </button>
      </div>
    <% end %>
    """
  end

  defp square_id(row, column),
    do: String.to_atom("sq#{Integer.to_string(row)}#{Integer.to_string(column)}")

  def player_tile_color(%GameState{status: :done} = game, player, _local_player) do
    case GameState.result(game) do
      :draw ->
        "bg-gray-400"

      ^player ->
        "bg-green-400"

      %Player{} ->
        "bg-red-400"

      _else ->
        "bg-gray-400"
    end
  end

  def player_tile_color(%GameState{status: :playing} = game, player, local_player) do
    if GameState.player_turn?(game, player) do
      if player == local_player do
        "bg-green-400"
      else
        "bg-gray-400"
      end
    else
      "bg-gray-400"
    end
  end

  def square(%Player{} = player, %GameState{status: :done} = game, square_name, opts) do
    opponent = GameState.opponent(game, player)

    winning_squares =
      case GameState.check_for_player_win(game, player) do
        :not_found -> []
        [_, _, _] = winning_spaces -> winning_spaces
      end

    losing_squares =
      case GameState.check_for_player_win(game, opponent) do
        :not_found -> []
        [_, _, _] = losing_spaces -> losing_spaces
      end

    color =
      cond do
        Enum.member?(winning_squares, square_name) -> "bg-green-200"
        Enum.member?(losing_squares, square_name) -> "bg-red-200"
        true -> "bg-white"
      end

    case GameState.find_square(game, square_name) do
      {:ok, sq} ->
        render_square(sq.letter, color, opts)

      _not_found ->
        render_square(nil, "bg-white", opts)
    end
  end

  def square(%Player{} = _player, %GameState{status: :playing} = game, square_name, opts) do
    case GameState.find_square(game, square_name) do
      {:ok, %Square{} = square} ->
        render_square(square.letter, "bg-white", opts)

      _not_found ->
        render_square(nil, "bg-white", opts)
    end
  end

  def square(_player, _game, _square_name, _opts), do: nil

  def render_square(letter, color, opts) do
    classes = "m-2 sm:m-4 w-full h-22 rounded-md #{color} cursor-pointer"

    Phoenix.HTML.Tag.content_tag :span, Keyword.merge(opts, class: classes) do
      case letter do
        nil ->
          Phoenix.HTML.raw({:safe, "&nbsp;"})

        letter ->
          letter
      end
    end
  end

  def result(%GameState{status: :done} = state) do
    case GameState.result(state) do
      :draw ->
        "Tie game!"

      %Player{name: winner_name} ->
        "#{winner_name} wins!"
    end
  end

  def result(%GameState{} = _state) do
    ""
  end
end
