require 'spec_helper'

describe CanvasOauth::CanvasApiExtensions do
  describe "build" do
    subject { CanvasOauth::CanvasApiExtensions.build('http://test.canvas', 1, 'abc123') }

    before { CanvasOauth::Authorization.stub(:fetch_token).with(1, 'abc123').and_return('token') }

    it { should be_a CanvasOauth::CanvasApi }
    its(:token) { should == 'token' }
    its(:canvas_url) { should == 'http://test.canvas' }
  end
end
