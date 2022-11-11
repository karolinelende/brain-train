defmodule BrainTrainWeb.Presence do
  use Phoenix.Presence,
    otp_app: :brain_train,
    pubsub_server: BrainTrain.PubSub
end
