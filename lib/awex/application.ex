defmodule Awex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Awex.AA,
      # Start the Ecto repository
      Awex.Repo,
      # Start the Telemetry supervisor
      AwexWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Awex.PubSub},
      # Start the Endpoint (http/https)
      AwexWeb.Endpoint
      # Start a worker by calling: Awex.Worker.start_link(arg)
      # {Awex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Awex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AwexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
