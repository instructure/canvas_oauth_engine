module CanvasOauth
  module CanvasApplication
    extend ActiveSupport::Concern

    module ClassMethods
    end

    included do
      include CanvasCache

      helper_method :canvas

      rescue_from CanvasApi::Authenticate, with: :reauthenticate
      rescue_from CanvasApi::Unauthorized, with: :unauthorized_canvas_access

      before_filter :request_canvas_authentication
    end

    protected
    def initialize_canvas
      @canvas = ::CanvasOauth::CanvasApiExtensions.build(canvas_url, user_id, tool_consumer_instance_guid)
    end

    def canvas
      @canvas || initialize_canvas
    end

    def canvas_token
      ::CanvasOauth::Authorization.fetch_token(user_id, tool_consumer_instance_guid)
    end

    def request_canvas_authentication
      if !params[:code].present? && !canvas_token.present?
        redirect_to canvas.auth_url(canvas_oauth_url)
      end
    end

    def not_acceptable
      render text: "Unable to process request", status: 406
    end

    def unauthorized_canvas_access
      render text: "Your Canvas Developer Key is not authorized to access this data.", status: 401
    end

    def reauthenticate
      ::CanvasOauth::Authorization.clear_tokens(user_id, tool_consumer_instance_guid)
      request_canvas_authentication
    end

    # these next three methods rely on external session data and either need to
    # be overridden or the session data needs to be set up by the time the
    # oauth filter runs (like with the lti_provider_engine)

    def canvas_url
      session[:canvas_url]
    end

    def user_id
      session[:user_id]
    end

    def tool_consumer_instance_guid
      session[:tool_consumer_instance_guid]
    end
  end
end
