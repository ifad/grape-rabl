require 'spec_helper'

describe Grape::RablRails do
  subject { Class.new(Grape::API) }

  before do
    subject.default_format :xml
    subject.formatter :xml, Grape::Formatter::RablRails.new(views: view_root)
  end

  context "with xml format"  do

    it "should respond with proper content-type" do
      subject.get("/home", :rabl => "empty")
      get("/home")
      last_response.headers["Content-Type"].should == "application/xml"
    end

    it "should render rabl template" do
      subject.get("/home", :rabl => :user) do
        @user = OpenStruct.new(:name => "LTe", :email => "email@example.com")
        @project = OpenStruct.new(:name => "First")
      end

      get "/home"

      last_response.body.should == %Q{<?xml version="1.0" encoding="UTF-8"?>\n<user>\n  <name>LTe</name>\n  <email>email@example.com</email>\n  <project>\n    <name>First</name>\n  </project>\n</user>\n}
    end
  end
end
