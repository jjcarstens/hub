defmodule HubApi.Router do
  use HubApi, :router

  pipeline :hub_api do
    plug :accepts, ["json"]
    plug HubApi.Auth
  end

  scope "/", HubApi do
    pipe_through :hub_api

    get "/whose_turn", SelectionController, :turn_picker

    scope "/fan" do
      put "/light", RadioController, :fan_light
      put "/:speed", RadioController, :fan_speed
    end

    scope "/outlet" do
      put "/:outlet_id/:toggle", RadioController, :outlet
    end

    scope "/storage_room" do
      get "/", StorageRoomController, :index
      get "/:type", StorageRoomController, :show
      put "/:type/:toggle", StorageRoomController, :update
    end
  end
end
