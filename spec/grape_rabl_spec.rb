require 'spec_helper'

describe Grape::RablRails do
  subject { Class.new(Grape::API) }

  before do
    subject.default_format :json
    subject.formatter :json, Grape::Formatter::RablRails.new(views: view_root)
    subject.formatter :xml , Grape::Formatter::RablRails.new(views: view_root)
    subject.helpers MyHelper
  end

  it 'should work without rabl template and yield json by default' do
    subject.get("/home") {"Hello World"}
    get "/home"
    last_response.body.should == "\"Hello World\""
  end

  it 'should work without rabl template and yield xml if requested' do
    subject.get("/home") { Hash[hello: :world] }
    get "/home.xml"
    last_response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <hello type=\"symbol\">world</hello>\n</hash>\n"
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

  context "a grape namespace" do
    it "namespaces the rabl view path" do
      subject.namespace :foo do
        get '/bar', rabl: 'bar' do
          @quux = OpenStruct.new(:fooed => 'yay', :bared => 'nay')
        end
      end

      get '/foo/bar' do
        last_response.body.should == '{"quux":{"fooed":"yay","bared":"nay"}}'
      end
    end
  end

end
