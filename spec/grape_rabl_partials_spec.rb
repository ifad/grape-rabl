require 'spec_helper'

describe "Grape::RablRails partials" do
  subject { Class.new(Grape::API) }

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::RablRails.new(views: view_root)
  end

  it "proper render partials" do
    subject.get("/home", :rabl => "project") do
      @author   = OpenStruct.new(:author => "LTe")
      @type     = OpenStruct.new(:type => "paper")
      @project  = OpenStruct.new(:name => "First", :type => @type, :author => @author)
    end

    get("/home")
    last_response.body.should ==
      "{\"project\":{\"name\":\"First\",\"info\":{\"type\":\"paper\"},\"author\":{\"author\":\"LTe\"}}}"
  end
end
