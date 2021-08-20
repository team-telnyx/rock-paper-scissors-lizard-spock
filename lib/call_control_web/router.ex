defmodule CallControlWeb.Router do
  use CallControlWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webhook", CallControlWeb do
    pipe_through :api

    post "/multiplayer", WebhookController, :multiplayer
    post "/singleplayer", WebhookController, :singleplayer
  end
end
