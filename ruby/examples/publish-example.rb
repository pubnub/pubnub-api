##including required libraries   
require './lib/pubnub.rb'
require 'json'

##declaring publish_key, subscribe_key, secret_key, cipher_key, message
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key = 'demo'
channel = 'hello_world'
ssl_on        = !!ARGV[4]

strMessage = "hey what is up?"
arrMessage =  ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
objMessage ={"desc"=>"someKey","main_item"=>"item1"}  #{"name"=>"Jhon","Age"=>"23"}

## Print usage if missing info.
if !strMessage && arrMessage && objMessage
  puts('
  Get API Keys at http://www.pubnub.com/account
  ==============
  EXAMPLE USAGE:
  ==============
  ruby publish-example.rb PUB-KEY SUB-KEY SECRET-KEY "message text" SSL-ON
  ruby publish-example.rb demo demo "demo" "hey what is up?" true
  ')
    exit()
 end

## Create Pubnub Client API (INITIALIZATION)

puts('Creating new Pubnub Client API')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on=false)

## Send Message (PUBLISH) --string 

puts('Sending message in string format with publish() Function')
info = pubnub.publish({'channel' => channel ,'message' => strMessage})
puts("\n",info)
  
## Send Message (PUBLISH) -- Array
puts('Sending message in array format with publish() Function')
info = pubnub.publish({'channel' => channel ,'message' => arrMessage})
puts("\n",info)
## Send Message (PUBLISH) -- Object(Dictionary)
puts('Sending message in object format with publish() Function')
info = pubnub.publish({'channel' => channel ,'message' => objMessage})
## Print Pretty
puts("\n",info)

