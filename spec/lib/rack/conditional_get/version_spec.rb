require "spec_helper"

describe Rack::ConditionalGet::VERSION do
  it "should be a string" do
    expect(Rack::ConditionalGet::VERSION).to be_kind_of(String)
  end
end
