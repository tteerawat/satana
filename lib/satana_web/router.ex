defmodule SatanaWeb.Router do
  use SatanaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SatanaWeb.API do
    pipe_through :api

    get "/transactions/:status", TransactionController, :list_transactions
    post "/transactions", TransactionController, :add_transaction
  end

  scope "/webhook", SatanaWeb.Webhook do
    pipe_through :api

    post "/blocknative", BlocknativeController, :handle_webhook
  end
end
