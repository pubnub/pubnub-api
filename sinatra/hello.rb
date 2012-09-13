require 'sinatra'
require 'sinatra/hashfix'
require 'pubnub'

def my_callback(message)
  get '/h' do
    return message.to_s
  end
end

def my_stream(message)
  puts(message)
  body message.to_s
  halt
end

#callback = method(:my_callback)
#pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
#pubnub.publish(:channel => :hello_world, :callback => callback, :message => "#{Time.now} - Ladies and Gentlemen, Sinatra!")

get '/streamer' do
  my_out = method(:my_stream)

  pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  pubnub.subscribe(:channel => :hello_world, :callback => my_out)


end