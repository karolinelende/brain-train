defmodule BrainTrainWeb.SessionController do
  use BrainTrainWeb, :controller

  def set(conn, %{"name" => username}), do: store_string(conn, :username, username)

  defp store_string(conn, key, value) do
    conn
    |> put_session(key, value)
    |> json("OK!")
  end
end
