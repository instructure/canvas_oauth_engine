class CreateCanvasOauthAuthorizations < ActiveRecord::Migration
  def change
    create_table "canvas_oauth_authorizations", :force => true do |t|
      t.integer  "canvas_user_id", :limit => 8
      t.string   "tool_consumer_instance_guid", :null => false
      t.string   "token"
      t.datetime "last_used_at"
      t.datetime "created_at",                  :null => false
      t.datetime "updated_at",                  :null => false
    end
  end
end
