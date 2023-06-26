defmodule Parry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ParryWeb.Telemetry,
      # Start the Ecto repository
      Parry.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Parry.PubSub},
      # Start Finch
      {Finch, name: Parry.Finch},
      # Start the Endpoint (http/https)
      ParryWeb.Endpoint
      # Start a worker by calling: Parry.Worker.start_link(arg)
      # {Parry.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Parry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
