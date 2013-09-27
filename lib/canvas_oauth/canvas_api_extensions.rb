module CanvasOauth
  class CanvasApiExtensions
    def self.build(canvas_url, user_id, tool_consumer_instance_guid)
      token = CanvasOauth::Authorization.fetch_token(user_id, tool_consumer_instance_guid)
      CanvasApi.new(canvas_url, token, CanvasConfig.key, CanvasConfig.secret)
    end
  end
end
