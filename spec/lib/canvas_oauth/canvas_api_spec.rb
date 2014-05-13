require 'spec_helper'

describe CanvasOauth::CanvasApi do
  let(:canvas) { CanvasOauth::CanvasApi.new('http://test.canvas', 'token', 'key', 'secret') }

  describe "initializer" do
    subject { canvas }

    its(:canvas_url) { should == 'http://test.canvas' }
    its(:token) { should == 'token' }
    its(:key) { should == 'key' }
    its(:secret) { should == 'secret' }
  end

  describe "auth_url" do
    subject { canvas.auth_url('http://localhost:3001/canvas/oauth', 'zzxxyy') }

    it { should == "http://test.canvas/login/oauth2/auth?client_id=key&response_type=code&state=zzxxyy&redirect_uri=http://localhost:3001/canvas/oauth" }
  end

  describe "get_access_token" do
    it "POSTs to /login/oauth2/token" do
      CanvasOauth::CanvasApi.should_receive(:post).with('/login/oauth2/token', anything()).and_return({})
      canvas.get_access_token('code')
    end

    it "returns the access token" do
      CanvasOauth::CanvasApi.stub(:post).and_return({ 'access_token' => 'token' })
      canvas.get_access_token('code').should == 'token'
    end

    it "sends the key, secret, and code as params" do
      params = {
        body: {
          client_id: 'key',
          client_secret: 'secret',
          code: 'code'
        }
      }

      CanvasOauth::CanvasApi.should_receive(:post).with(anything(), params).and_return({})
      canvas.get_access_token('code')
    end
  end

  describe "requests" do
    describe "authenticated_request" do
      it "passes the params along as-is and adds an Authorization header" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/path', { query: 'stuff', headers: { 'Authorization' => 'Bearer token' } })
        canvas.authenticated_request :get, '/path', { query: 'stuff' }
      end

      it "raises an authenticate error when the response is a 401 and WWW-Authenticate is set" do
        CanvasOauth::CanvasApi.stub(:get).and_return(double(unauthorized?: true, headers: { 'WWW-Authenticate' => true }))
        expect { canvas.authenticated_request :get, '/path' }.to raise_error CanvasOauth::CanvasApi::Authenticate
      end

      it "raises an unauthorized error when the response is a 401" do
        CanvasOauth::CanvasApi.stub(:get).and_return(double(unauthorized?: true, headers: {}))
        expect { canvas.authenticated_request :get, '/path' }.to raise_error CanvasOauth::CanvasApi::Unauthorized
      end
    end

    describe "get_courses" do
      it "queries /api/v1/courses" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/courses', anything())
        canvas.get_courses
      end
    end

    describe "get_account_courses" do
      it "queries /api/v1/accounts/:id/courses" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/accounts/1/courses', anything())
        canvas.get_account_courses(1)
      end

      it "paginates" do
        canvas.should_receive(:paginated_get)
        canvas.get_account_courses(1)
      end
    end

    describe "get account users" do
      it "queries /api/v1/accounts/:id/users" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/accounts/1/users', anything())
        canvas.get_account_users(1)
      end

      it "paginates" do
        canvas.should_receive(:paginated_get)
        canvas.get_account_users(1)
      end
    end

    describe "get_course" do
      it "queries /api/v1/courses/:id" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/courses/123', anything())
        canvas.get_course('123')
      end
    end

    describe "get_course_students" do
      it "queries /api/v1/courses/:id/students" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/courses/123/students', anything())
        canvas.get_course_students('123')
      end

      it "paginates" do
        canvas.should_receive(:paginated_get)
        canvas.get_course_students('123')
      end
    end

    describe "get_sections" do
      it "queries /api/v1/courses/:id/sections" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/courses/123/sections', anything())
        canvas.get_sections('123')
      end

      it "paginates" do
        canvas.should_receive(:paginated_get)
        canvas.get_sections('123')
      end
    end

    describe "get_assignments" do
      it "queries /api/v1/courses/:id/assignments" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/courses/123/assignments', anything())
        canvas.get_assignments('123')
      end

      it "paginates" do
        canvas.should_receive(:paginated_get)
        canvas.get_account_courses('123')
      end
    end

    describe "get_user_profile" do
      it "queries /api/v1/users/:id/profile" do
        CanvasOauth::CanvasApi.should_receive(:get).with('/api/v1/users/123/profile', anything())
        canvas.get_user_profile('123')
      end
    end

    describe "create_assignment" do
      it "posts to /api/v1/courses/:id/assignments" do
        CanvasOauth::CanvasApi.should_receive(:post).with('/api/v1/courses/123/assignments', anything())
        canvas.create_assignment('123', name: "Assignment")
      end

      it "sets the body of the request to the assignment params" do
        canvas.should_receive(:authenticated_post).with(anything(), { body: { assignment: { name: "Assignment" }}})
        canvas.create_assignment('123', name: "Assignment")
      end
    end

    describe "grade_assignment" do
      it "puts to /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:id" do
        CanvasOauth::CanvasApi.should_receive(:put).with('/api/v1/courses/1/assignments/2/submissions/3', anything())
        canvas.grade_assignment('1', '2', '3', {})
      end

      it "sets the body of the request to the grade params" do
        canvas.should_receive(:authenticated_put).with(anything(), { body: { percentage: "80%" }})
        canvas.grade_assignment('1', '2', '3', percentage: "80%")
      end
    end
  end

  describe "pagination" do
    describe "valid_page?" do
      let(:valid_page) { double(size: 2, nil?: false, body: '[{some:json}]') }
      let(:same_page) { valid_page }
      let(:blank_page) { double(size: 0, nil?: false, body: '[]') }

      specify { canvas.valid_page?(nil).should be_false }
      specify { canvas.valid_page?(valid_page).should be_true }
      specify { canvas.valid_page?(blank_page).should be_false }
    end

    describe "paginated_get" do
      it "adds per_page parameters to the request query" do
        canvas.should_receive(:authenticated_get).with("/some/address", query: { per_page: 50 })
        canvas.paginated_get "/some/address"
      end

      it "requests the next link" do
        canvas.stub(:valid_page?) { true }
        first_response = []
        second_response = []
        first_response.stub(headers: {'link' => "<https://foobar.com/some/address?page=2>; rel=\"next\", <https://foobar.com/some/address?page=2>; rel=\"last\""})
        second_response.stub(headers: {})
        canvas.should_receive(:authenticated_get).
          exactly(2).times.and_return(first_response,second_response)
        canvas.paginated_get "/some/address"
      end

      it "sends only one request when no next link is in the response Link header" do
        canvas.stub(:valid_page?) { true }
        response = [{totally: "A real fake response"}]
        response.stub(headers: {})
        canvas.should_receive(:authenticated_get).once.and_return(response)
        canvas.paginated_get "/some/address"
      end

      it "sends just one request when an invalid result is returned" do
        canvas.stub(:valid_page?) { false }
        response = []
        response.stub(headers: {})
        canvas.should_receive(:authenticated_get).once.and_return(response)
        canvas.paginated_get "/some/address"
      end
    end
  end

  describe "course_account_id" do
    it "returns the 'account_id' of a course" do
      canvas.stub(:get_course).with(1).and_return('account_id' => 3)
      canvas.course_account_id(1).should == 3
    end
  end

  describe "hex_sis_id" do
    it "encodes the passed in ID and creates an SIS ID string" do
      canvas.hex_sis_id("sis_course_id", "101").should == "hex:sis_course_id:313031"
    end
  end
end
