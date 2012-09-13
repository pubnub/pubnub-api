require 'sinatra'
require 'sinatra/hashfix'
require 'pubnub'

def my_callback(message)
  get '/h' do
    return message.to_s
  end
end

def sub_out(message)
  puts(message[0].to_s)
  halt message[0].to_s if message[0] != []
end

def pub_out(message)
  puts(message[0].to_s)
  halt message[0].to_s if message[0] != []
end

#callback = method(:my_callback)
#pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
#pubnub.publish(:channel => :hello_world, :callback => callback, :message => "#{Time.now} - Ladies and Gentlemen, Sinatra!")

get '/sub' do
  my_sub_callback = method(:sub_out)

  pubnub = Pubnub.new(:subscribe_key => :demo)
  pubnub.subscribe(:channel => :hello_world, :callback => my_sub_callback)
end

get '/pub:message' do
  my_pub_callback = method(:pub_out)

  pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  pubnub.publish(:channel => :hello_world, :callback => my_pub_callback, :message => "#{Time.now} - Sinatra says #{params[:message].to_s}!")
end