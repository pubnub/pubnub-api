require File.dirname(__FILE__) + '/hello.rb'
require 'rack/test'

set :enviroment, :test

def app
  Sinatra::Application
end

# GET /pub/:message
describe "responding to GET pub" do
  include Rack::Test::Methods

  it "should send message" do
    get '/pub/hi'

    last_response.should be_ok
  end

end

# GET /time
describe "responding to GET time" do
  include Rack::Test::Methods

  it "should return server time" do
    get '/time'
    
    last_response.should be_ok
  end

end

# GET /uuid
describe "responding to GET uuid" do
  include Rack::Test::Methods

  it "should return session UUID" do

    get '/uuid'

    last_response.should be_ok
  end

end

# GET /here_now
describe "responding to GET here_now" do
  include Rack::Test::Methods

  it "should return current occupancy status of the channel" do
    
    get '/here_now'

    last_response.should be_ok
  end

end

# GET /history
describe "responding to GET history" do
  include Rack::Test::Methods

  it "should return the last 5 messages published to the channel" do
    get '/history'

    last_response.should be_ok
  end

end

# GET /detailed_history
describe "responding to GET detailed_history" do
  include Rack::Test::Methods

  it "should return archive messages of on a given channel" do
    get '/detailed_history'

    last_response.should be_ok
  end

end


