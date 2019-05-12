defmodule HubApi.Router do
  use HubApi, :router

  pipeline :hub_api do
    plug :accepts, ["json"]
    plug HubApi.Auth
  end

  scope "/", HubApi do
    pipe_through :hub_api

    get "/whose_turn", SelectionController, :turn_picker
  end
end
