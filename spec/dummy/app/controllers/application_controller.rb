class ApplicationController < ActionController::Base
  include CanvasOauth::CanvasApplication

  protect_from_forgery
end
