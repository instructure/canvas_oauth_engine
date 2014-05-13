module CanvasOauth
  class CanvasController < CanvasOauth::ApplicationController
    skip_before_filter :request_canvas_authentication

    def oauth
      if verify_oauth2_state(params[:state]) && params[:code]
        if token = canvas.get_access_token(params[:code])
          if CanvasOauth::Authorization.cache_token(token, user_id, tool_consumer_instance_guid)
            redirect_to main_app.root_path
          else
            render text: "Error: unable to save token"
          end
        else
          render text: "Error: invalid code - #{params[:code]}"
        end
      else
        render text: "#{CanvasOauth::Config.tool_name} needs access to your account in order to function properly. Please try again and click log in to approve the integration."
      end
    end

    def verify_oauth2_state(callback_state)
      callback_state.present? && callback_state == session.delete(:oauth2_state)
    end
  end
end
