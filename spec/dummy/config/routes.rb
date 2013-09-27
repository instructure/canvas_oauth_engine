Rails.application.routes.draw do
  root to: "welcome#index"
  mount CanvasOauth::Engine => "/"
end
