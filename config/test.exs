use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :satana, SatanaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# blocknative
config :satana, Satana.Blocknative.Config,
  basic_auth: [
    username: "test",
    password: "test"
  ]
