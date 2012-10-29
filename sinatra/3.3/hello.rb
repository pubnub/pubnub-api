require 'sinatra'
require 'sinatra/hashfix'
require 'pubnub'

# callback
# if output returns false, return immediately, otherwise, keep going...
def output(out, cycle = false); p out; cycle; end

# presence route
get '/presence' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.presence(:channel => :hello_world, :callback => method(:output))
end

# subscribe route
get '/sub' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.subscribe(:channel => :hello_world, :callback => method(:output))
end

# publish route
get '/pub/:message' do
  pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  pubnub.publish(:channel => :hello_world, :callback => method(:output), :message => "#{Time.now} - Sinatra says #{params[:message]}!")
end

# message detailed_history route
get '/detailed_history' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.detailed_history(:channel => :hello_world, :count => 5, :callback => method(:output))
end

# message history route
get '/history' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.history(:channel => :hello_world, :limit => 5, :callback => method(:output))
end

# here_now route
get '/here_now' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.here_now(:channel => :hello_world, :count => 5, :callback => method(:output))
end

# time route
get '/time' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.time(:callback => method(:output))
end

# uuid route
get '/uuid' do
  pubnub = Pubnub.new(:subscribe_key => :demo)
  output(pubnub.uuid)
end