require 'sinatra'
require 'sinatra/hashfix'
require 'pubnub'

# presence callback
def presence_out(message)
  body_out = message[0].to_s
  puts(message)
  halt body_out if message[0] != []
end

# subscribe callback
def sub_out(message)
  body_out = message[0].to_s
  puts(body_out)
  halt body_out if message[0] != []
end

# publish callback
def pub_out(message)
  body_out = message[0].to_s
  puts(body_out)
  halt body_out if message[0] != []
end

# uuid callback
def uuid_out(message)
  body_out = "#{message}"
  puts(body_out)
  halt body_out
end

# time callback
def time_out(message)
  body_out = "#{message[0].to_s}"
  puts(body_out)
  halt body_out
end

# message history callback
def history_out(message)
  body_out = "#{message[0].to_s}, starting at: #{message[1]}, ending at: #{message[2]}"
  puts(body_out)
  halt body_out
end

# here_now callback
def here_now_out(message)
  body_out = "UUIDS: #{message["uuids"].to_s}<br/>Occupancy: #{message["occupancy"]}"
  puts(message)
  halt body_out
end

# presence route
get '/presence' do
  my_presence_callback = method(:presence_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.presence(:channel => :hello_world, :callback => my_presence_callback)
end

# subscribe route
get '/sub' do
  my_sub_callback = method(:sub_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.subscribe(:channel => :hello_world, :callback => my_sub_callback)
end

# publish route
get '/pub/:message' do
  my_pub_callback = method(:pub_out)

  pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  pubnub.publish(:channel => :hello_world, :callback => my_pub_callback, :message => "#{Time.now} - Sinatra says #{params[:message]}!")
end

# message history route
get '/history' do
  my_history_callback = method(:history_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.detailed_history(:channel => :hello_world, :count => 5, :callback => my_history_callback)
end

# here_now route
get '/here_now' do
  my_here_now_callback = method(:here_now_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.here_now(:channel => :hello_world, :count => 5, :callback => my_here_now_callback)
end

# time route
get '/time' do
  my_time_callback = method(:time_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.time(:callback => my_time_callback)
end

# uuid route
get '/uuid' do
  my_uuid_callback = method(:uuid_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  uuid_out(pubnub.uuid)
end