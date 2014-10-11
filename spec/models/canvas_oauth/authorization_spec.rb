require 'spec_helper'

describe CanvasOauth::Authorization do
  it { is_expected.to validate_presence_of :canvas_user_id }
  it { is_expected.to validate_presence_of :token }
  it { is_expected.to validate_presence_of :last_used_at }

  describe "cache_token" do
    subject { CanvasOauth::Authorization.first }

    before do
      CanvasOauth::Authorization.cache_token('abc', 123, 'abc123')
    end

    its(:token) { is_expected.to eq 'abc' }
    its(:canvas_user_id) { is_expected.to eq 123 }
    its(:tool_consumer_instance_guid) { is_expected.to eq 'abc123' }
    its(:last_used_at) { is_expected.to be_present }
  end

  describe "fetch_token" do
    subject(:token) { CanvasOauth::Authorization.fetch_token(123, 'abc123') }

    context "when a token exists" do
      before do
        CanvasOauth::Authorization.cache_token('abc', 123, 'abc123')
        CanvasOauth::Authorization.cache_token('def', 123, 'abc123')
      end

      it "retrieves the latest one" do
        expect(token).to eq 'def'
      end
    end

    context "when a token exists with a tool_consumer_instance_guid" do
      before do
        CanvasOauth::Authorization.cache_token('abc', 123, 'wrong')
      end

      it { is_expected.to be_nil }
    end

    context "when no token exists" do
      it { is_expected.to be_nil }
    end
  end
end
