Rails.application.routes.draw do
  root to: "welcome#index"
  mount CanvasOauth::Engine => "/canvas_oauth"
end
