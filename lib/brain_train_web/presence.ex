defmodule BrainTrainWeb.Presence do
  use Phoenix.Presence,
    otp_app: :brain_train,
    pubsub_server: BrainTrain.PubSub

  @presence "users:presence"

  def channel_name, do: @presence

  def join_session(nil), do: :ok

  def join_session(user) do
    {:ok, _} =
      track(self(), @presence, get_temp_id(), %{
        name: user,
        joined_at: :os.system_time(:seconds)
      })
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
end
