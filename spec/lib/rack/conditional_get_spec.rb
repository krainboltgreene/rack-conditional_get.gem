require "spec_helper"

describe Rack::ConditionalGet do
  let(:application) { instance_double("Application") }
  let(:middleware) { described_class.new(application) }
  let(:verb) { "GET" }
  let(:status) { 200 }
  let(:headers) do
    {
      "REQUEST_METHOD" => verb,
      "Content-Type" => "text/plain",
      "Content-Length" => "0"
    }
  end
  let(:body) { "" }

  before(:each) do
    allow(application).to receive(:call).and_return([status, headers, body])
  end

  describe "#call" do
    context "with If-Modified-Since set" do
      let(:modified_sense) { Time.now }
      it "returns 304"
      it "removes Content-Type"
      it "removes Content-Length"
    end

    context "with If-None-Match set" do
      let(:none_match) { Time.now }
      it "returns 304"
      it "removes Content-Type"
      it "removes Content-Length"
    end
  end
end
