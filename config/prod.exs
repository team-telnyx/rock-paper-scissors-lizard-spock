use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

config :call_control, CallControlWeb.Endpoint, server: true
