CanvasOauth::Engine.routes.draw do
  match "/", to: "canvas#oauth", via: :get, as: :canvas_oauth
end
