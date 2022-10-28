defmodule BrainTrainWeb.LayoutView do
  use BrainTrainWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])

    if path == current_path do
      " bg-gray-900 text-white"
    else
      " text-gray-300"
    end
  end

  def active_link(conn, text, opts) do
    class =
      [opts[:class], active_class(conn, opts[:to])]
      |> Enum.filter(& &1)
      |> Enum.join("")

    opts =
      opts
      |> Keyword.put(:class, class)

    link(text, opts)
  end
end
