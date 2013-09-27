require 'spec_helper'

describe CanvasOauth::CanvasCache do
  let(:object) { Object.new }
  before { object.extend(CanvasOauth::CanvasCache) }

  describe "cache_response" do
    it "sets the response in redis as JSON" do
      response = { hash: "value" }
      object.cache_response("key", response)
      object.redis.get('key').should == response.to_json
    end
  end

  describe "cached_response" do
    let(:request) { lambda { { 'source' => 'lambda' } } }

    it "hits redis up first" do
      object.redis.should_receive(:get).with("key").and_return('{"source":"redis"}')
      request.should_not_receive(:call)
      object.cached_response("key", request)['source'].should == 'redis'
    end

    it "calls the lambda if redis returns nil" do
      object.redis.should_receive(:get).with("key").and_return(nil)
      object.cached_response("key", request)['source'].should == 'lambda'
    end

    context "hitting the canvas API" do
      before do
        object.redis.stub(:get)
        stub_request(:get, "http://canvas/account.json").to_return(:status => 200, body: "{\"id\":3}", headers: {'Content-Type' => 'application/json'})
      end

      it "handles HTTParty::Responses properly" do
        request = double(call: HTTParty.get("http://canvas/account.json"))
        object.cached_response("key", request)['id'].should == 3
      end

      it "handles arrays (paginated results) properly" do
        request = double(call: [HTTParty.get("http://canvas/account.json")])
        object.cached_response("key", request).first['id'].should == 3
      end
    end
  end

  describe "redis_key" do
    specify { object.redis_key(:section, 1).should == "section:1" }
  end
end
