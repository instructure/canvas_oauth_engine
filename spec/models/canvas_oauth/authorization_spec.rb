require 'spec_helper'

describe CanvasOauth::Authorization do
  it { should validate_presence_of :canvas_user_id }
  it { should validate_presence_of :token }
  it { should validate_presence_of :last_used_at }

  describe "cache_token" do
    subject { CanvasOauth::Authorization.first }

    before do
      CanvasOauth::Authorization.cache_token('abc', 123, 'abc123')
    end

    its(:token) { should == 'abc' }
    its(:canvas_user_id) { should == 123 }
    its(:tool_consumer_instance_guid) { should == 'abc123' }
    its(:last_used_at) { should be_present }
  end

  describe "fetch_token" do
    subject(:token) { CanvasOauth::Authorization.fetch_token(123, 'abc123') }

    context "when a token exists" do
      before do
        CanvasOauth::Authorization.cache_token('abc', 123, 'abc123')
        CanvasOauth::Authorization.cache_token('def', 123, 'abc123')
      end

      it "retrieves the latest one" do
        token.should == 'def'
      end
    end

    context "when a token exists with a tool_consumer_instance_guid" do
      before do
        CanvasOauth::Authorization.cache_token('abc', 123, 'wrong')
      end

      it { should be_nil }
    end

    context "when no token exists" do
      it { should be_nil }
    end
  end
end
