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

      subject.get("/home", rabl: "helper") { @user = OpenStruct.new }
      get "/home"
      last_response.body.should == "{\"user\":{\"helper\":\"my_helper\"}}"
    end
  end

  describe "#render" do
    before do
      subject.get("/home", rabl: "user") do
        @user = OpenStruct.new(name: "LTe")
        render rabl: "admin"
      end

      subject.get("/about", rabl: "user") do
        @user = OpenStruct.new(name: "LTe")
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
    subject.get("/home", rabl: "empty") {}
    get("/home")
    last_response.headers["Content-Type"].should == "application/json"
  end

  it "should be successful" do
    subject.get("/home", rabl: "empty") {}
    get "/home"
    last_response.status.should == 200
  end

  it "should render rabl template" do
    subject.get("/home", rabl: "user") do
      @user = OpenStruct.new(name: "LTe", email: "email@example.com")
      @project = OpenStruct.new(name: "First")
    end

    get "/home"
    last_response.body.should == '{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'
  end

  context "a grape namespace" do
    it "namespaces the rabl view path" do
      subject.namespace :foo do
        get '/bar', rabl: 'bar' do
          @quux = OpenStruct.new(fooed: 'yay', bared: 'nay')
        end
      end

      get '/foo/bar'
      last_response.body.should == '{"quux":{"fooed":"yay","bared":"nay"}}'
    end

    it "doesn't namespace the rabl view path if the template in route options starts with /" do
      subject.namespace :foo do
        get '/user', rabl: '/user' do
          @user = OpenStruct.new(name: 'Lleir', email: 'foo@example.com')
          @project = OpenStruct.new(name: 'brunello')
        end
      end

      get '/foo/user'
      last_response.body.should == '{"user":{"name":"Lleir","email":"foo@example.com","project":{"name":"brunello"}}}'
    end

    context "with multiple actions" do
      before do
        subject.namespace :foo do
          get '/foo', rabl: 'bar' do
            @quux = OpenStruct.new(fooed: 'yay', bared: 'nay')
          end
          get '/bar', rabl: 'bar' do
            @quux = OpenStruct.new(fooed: 'nay', bared: 'yay')
          end
          get '/ping', rabl: false do
            'pong'
          end
        end

        subject.namespace :bar, rabl: 'other' do
          get '/admin', rabl: 'user' do
            OpenStruct.new(name: 'vjt', coolness: 'average', level: 42)
          end
        end
      end

      it "allows setting the rabl template namespace" do
        get '/foo/foo'
        last_response.body.should == '{"quux":{"fooed":"yay","bared":"nay"}}'

        get '/foo/bar'
        last_response.body.should == '{"quux":{"fooed":"nay","bared":"yay"}}'
      end

      it "allows disabling rabl on an action" do
        get '/foo/ping'
        last_response.body.should == '"pong"'
      end

      it "allows specifying a different template on an action" do
        get '/bar/admin'
        last_response.body.should == '{"user":{"name":"vjt","coolness":"average","level":42}}'
      end
    end

    context "with nested namespaces" do
      before do
        subject.namespace :foo do
          namespace '/:id/bar' do
            get '/user', rabl: 'user' do
              OpenStruct.new(name: 'amedeo', nested: 'fully')
            end
          end

          namespace '/:id', rabl: 'bar' do
            get '/user', rabl: 'user' do
              OpenStruct.new(name: 'ivan', nested: 'customly')
            end
          end
        end
      end

      it 'concatenates components, skipping the param routes' do
        get '/foo/3/bar/user'
        last_response.body.should == '{"user":{"name":"amedeo","nested":"fully"}}'
      end

      it 'allows overriding a sub-namespace name' do
        get '/foo/3/user'
        last_response.body.should == '{"user":{"name":"ivan","nested":"customly"}}'
      end

    end
  end

  context 'the @result instance variable' do
    context 'explicit template declaration' do
      before do
        subject.get '/automagic', rabl: 'result' do
          OpenStruct.new(name: 'lleir', coolness: 'uber')
        end
      end

      it 'yields correct json' do
        get '/automagic.json'
        last_response.body.should == '{"user":{"name":"lleir","coolness":"uber"}}'
      end

      it 'yields correct xml root' do
        get '/automagic.xml'
        last_response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>\n  <name>lleir</name>\n  <coolness>uber</coolness>\n</user>\n"
      end
    end
  end

  context 'conditional rabl rendering' do
    before do
      subject.get '/foo', rabl: 'result', rabl_if: :present?.to_proc do
        nil
      end
    end

    it "doesn't rabl" do
      get '/foo.json'
      last_response.body.should == 'null'
    end
  end

end
