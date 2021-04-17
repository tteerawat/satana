defmodule Satana.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    children =
      [
        SatanaWeb.Telemetry,
        {Phoenix.PubSub, name: Satana.PubSub},
        SatanaWeb.Endpoint,
        {Finch, name: Satana.Finch}
      ] ++ list_children_by_env(args[:env])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Satana.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SatanaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp list_children_by_env(:test) do
    []
  end

  defp list_children_by_env(_) do
    [Satana.ETHTransactions.Store]
  end
end
