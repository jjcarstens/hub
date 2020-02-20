defmodule HubWeb.Router do
  use HubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HubWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HubWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/admin", AdminLive
    live "/storage_room", StorageRoomLive
    live "/transaction/new", TransactionLive.New

    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    get "/privacy_policy", AuthController, :privacy_policy
  end

  scope "/auth", HubWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", HubWeb do
  #   pipe_through :api
  # end
end
