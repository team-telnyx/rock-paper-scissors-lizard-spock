import Config

config :call_control, :telnyx, api_key: System.fetch_env!("API_KEY")
config :call_control, host: System.fetch_env!("HOST")

config :call_control, CallControlWeb.Endpoint,
  http: [
    port: String.to_integer(System.fetch_env!("PORT")),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
