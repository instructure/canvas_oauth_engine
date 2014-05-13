require 'spec_helper'

describe CanvasOauth::CanvasController do
  describe "GET 'oauth'" do
    context "with a code" do
      context "valid" do
        before do
          controller.send(:canvas).stub(:get_access_token).with('valid') { 'token' }
          controller.stub(:verify_oauth2_state).with(nil) { true }
        end

        it "caches the token for the current user" do
          # test that the controller methods are used
          controller.stub(:user_id) { 1 }
          # but by default they delegate to the session
          session[:tool_consumer_instance_guid] = 'abc123'

          CanvasOauth::Authorization.should_receive(:cache_token).with('token', 1, 'abc123')
          get 'oauth', code: 'valid', use_route: :canvas_oauth
        end

        it "redirects to the root_path" do
          get 'oauth', code: 'valid', use_route: :canvas_oauth
          response.should redirect_to main_app.root_path
        end
      end

      context "invalid" do
        before do
          controller.send(:canvas).stub(:get_access_token).with('invalid') { nil }
          controller.stub(:verify_oauth2_state).with(nil) { true }
        end

        it "renders an error" do
          get 'oauth', code: 'invalid', use_route: :canvas_oauth
          response.body.should =~ /invalid code/
        end
      end
    end

    context "without a code" do
      it "renders an error" do
        controller.stub(:verify_oauth2_state).with(nil) { true }
        get 'oauth', use_route: :canvas_oauth
        response.body.should =~ /#{CanvasOauth::Config.tool_name} needs access to your account/
      end
    end

    context "with an oauth state callback" do
      before do
        controller.send(:canvas).stub(:get_access_token).with('valid') { 'token' }
      end

      it "works with a valid state" do
        session[:oauth2_state] = 'zzyyxx'
        get 'oauth', code: 'valid', state: 'zzyyxx', use_route: :canvas_oauth
        response.should redirect_to main_app.root_path
      end

      it "renders an error with an invalid state" do
        session[:oauth2_state] = 'zzyyxx'
        get 'oauth', code: 'valid', state: 'mismatch', use_route: :canvas_oauth
        response.body.should =~ /#{CanvasOauth::Config.tool_name} needs access to your account/
      end
    end

    context "without an oauth state callback" do
      it "in the session, renders an error" do
        get 'oauth', code: 'valid', state: 'zzyyxx', use_route: :canvas_oauth
        response.body.should =~ /#{CanvasOauth::Config.tool_name} needs access to your account/
      end

      it "in the params, renders an error" do
        session[:oauth2_state] = 'zzyyxx'
        get 'oauth', code: 'valid', use_route: :canvas_oauth
        response.body.should =~ /#{CanvasOauth::Config.tool_name} needs access to your account/
      end
    end
  end
end
