require 'spec_helper'

describe CanvasOauth::CanvasApiExtensions do
  describe "build" do
    subject { CanvasOauth::CanvasApiExtensions.build('http://test.canvas', 1, 'abc123') }

    before { allow(CanvasOauth::Authorization).to receive(:fetch_token).with(1, 'abc123').and_return('token') }

    it { is_expected.to be_a CanvasOauth::CanvasApi }
    its(:token) { is_expected.to eq 'token' }
    its(:canvas_url) { is_expected.to eq 'http://test.canvas' }
  end
end
