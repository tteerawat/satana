# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :satana, SatanaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eevCfIVUkprvBxi9P7+64i0e3d0sj8qcRu1NQUZeITcVLUxC0T8jtey/cSTjuuZg",
  render_errors: [view: SatanaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Satana.PubSub,
  live_view: [signing_salt: "aMkpdvkI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# blocknative
config :satana, Satana.Blocknative.Config,
  api_key: System.get_env("BLOCKNATIVE_API_KEY"),
  basic_auth: [
    username: System.get_env("BLOCKNATIVE_BASIC_AUTH_USERNAME"),
    password: System.get_env("BLOCKNATIVE_BASIC_AUTH_PASSWORD")
  ]

# slack
config :satana, Satana.Slack.Config, webhook_url: System.get_env("SLACK_WEBHOOK_URL")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
