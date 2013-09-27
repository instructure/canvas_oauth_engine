module CanvasOauth
  class Engine < ::Rails::Engine
    isolate_namespace CanvasOauth

    initializer "canvas_oauth.load_app_instance_data" do |app|
      CanvasOauth.setup do |config|
        config.app_root = app.root
      end
    end

    initializer "canvas_oauth.canvas_config" do |app|
      CanvasOauth::CanvasConfig.setup!
    end

    initializer "canvas_oauth.redis" do |app|
      CanvasOauth::RedisConfig.setup!
    end
  end
end
