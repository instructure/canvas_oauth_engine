module CanvasOauth
  class Authorization < ActiveRecord::Base
    validates :canvas_user_id, :token, :last_used_at, presence: true

    def self.cache_token(token, user_id, tool_consumer_instance_guid)
      create(
        token: token,
        canvas_user_id: user_id,
        last_used_at: Time.now,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      )
    end

    def self.fetch_token(user_id, tool_consumer_instance_guid)
      user_tokens = where(canvas_user_id: user_id, tool_consumer_instance_guid: tool_consumer_instance_guid).order("created_at DESC")
      if canvas_auth = user_tokens.first
        canvas_auth.update_attribute(:last_used_at, Time.now)
        return canvas_auth.token
      end
    end

    def self.clear_tokens(user_id, tool_consumer_instance_guid)
      where(canvas_user_id: user_id, tool_consumer_instance_guid: tool_consumer_instance_guid).destroy_all
    end
  end
end
