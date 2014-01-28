require 'spec_helper'

describe Grape::RablRails do
  subject { Class.new(Grape::API) }

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::RablRails.new(views: view_root)
    subject.helpers MyHelper
  end

  it 'should work without rabl template' do
    subject.get("/home") {"Hello World"}
    get "/home"
    last_response.body.should == "\"Hello World\""
  end

  describe "helpers" do
    it "should execute helper" do

      subject.get("/home", :rabl => "helper") { @user = OpenStruct.new }
      get "/home"
      last_response.body.should == "{\"user\":{\"helper\":\"my_helper\"}}"
    end
  end

  describe "#render" do
    before do
      subject.get("/home", :rabl => "user") do
        @user = OpenStruct.new(:name => "LTe")
        render :rabl => "admin"
      end

      subject.get("/about", :rabl => "user") do
        @user = OpenStruct.new(:name => "LTe")
      end
    end

    it "renders template passed as argument to reneder method" do
      get("/home")
      last_response.body.should == '{"admin":{"name":"LTe"}}'
    end

    it "does not save rabl options after called #render method" do
      get("/home")
      get("/about")
      last_response.body.should == '{"user":{"name":"LTe","email":null,"project":null}}'
    end
  end


  it "should respond with proper content-type" do
    subject.get("/home", :rabl => "empty") {}
    get("/home")
    last_response.headers["Content-Type"].should == "application/json"
  end

  it "should be successful" do
    subject.get("/home", :rabl => "empty") {}
    get "/home"
    last_response.status.should == 200
  end

  it "should render rabl template" do
    subject.get("/home", :rabl => "user") do
      @user = OpenStruct.new(:name => "LTe", :email => "email@example.com")
      @project = OpenStruct.new(:name => "First")
    end

    get "/home"
    last_response.body.should == '{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'
  end

end
