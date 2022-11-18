defmodule BrainTrain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BrainTrain.Repo,
      # Start the Telemetry supervisor
      BrainTrainWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BrainTrain.PubSub},
      BrainTrainWeb.Presence,
      # Start the registry for tracking running games
      {Horde.Registry, [name: BrainTrain.GameRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: BrainTrain.DistributedSupervisor,
         shutdown: 1000,
         strategy: :one_for_one,
         members: :auto
       ]},
      # Start the Endpoint (http/https)
      BrainTrainWeb.Endpoint
      # Start a worker by calling: BrainTrain.Worker.start_link(arg)
      # {BrainTrain.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BrainTrain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BrainTrainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
