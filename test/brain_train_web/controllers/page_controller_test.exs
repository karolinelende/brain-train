defmodule BrainTrainWeb.PageControllerTest do
  use BrainTrainWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to BrainTrain!"
  end
end
