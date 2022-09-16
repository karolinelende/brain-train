defmodule BrainTrainWeb.PageController do
  use BrainTrainWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
