defmodule BrainTrain.Repo do
  use Ecto.Repo,
    otp_app: :brain_train,
    adapter: Ecto.Adapters.Postgres
end
