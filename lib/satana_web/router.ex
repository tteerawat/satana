defmodule SatanaWeb.Router do
  use SatanaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SatanaWeb do
    pipe_through :api
  end
end
