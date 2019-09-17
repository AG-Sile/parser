require 'spec_helper'

describe API::ReviewParser do
  include Rack::Test::Methods

  let(:url) { CGI.escape('http://example.org:80/api/v1') }
  let(:parser_double) { instance_double('Parser')}

  describe "happy path" do
    it "returns the response from ReviewParser" do 
      allow(Parser).to receive(:new).and_return(parser_double)
      expect(parser_double).to receive(:parse_reviews)
        .with('http://example.org:80/api/v1')
        .and_return({'happy' => 'kitten'})
      get "/api/review_parser/#{url}"
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq({'happy' => 'kitten'}.to_json)
    end
  end

  describe "the url is uneachable" do
    it "returns 400 response" do 
      allow(Parser).to receive(:new).and_return(parser_double)
      expect(parser_double).to receive(:parse_reviews)
        .with('http://example.org:80/api/v1')
        .and_raise(Errno::ENOENT, "Oh no (intentionally thrown by the test")
      get "/api/review_parser/#{url}"
      expect(last_response.status).to eq 400
    end
  end

  describe "the url is uneachable in a different way" do
    it "returns 400 response" do 
      allow(Parser).to receive(:new).and_return(parser_double)
      expect(parser_double).to receive(:parse_reviews)
        .with('http://example.org:80/api/v1')
        .and_raise(SocketError, "Oh no (intentionally thrown by the test")
      get "/api/review_parser/#{url}"
      expect(last_response.status).to eq 400
    end
  end

  describe "Some other error" do
    it "returns 500 response" do 
      allow(Parser).to receive(:new).and_return(parser_double)
      expect(parser_double).to receive(:parse_reviews)
        .with('http://example.org:80/api/v1')
        .and_raise(StandardError, "Oh no (intentionally thrown by the test")
      get "/api/review_parser/#{url}"
      expect(last_response.status).to eq 500
    end
  end
end