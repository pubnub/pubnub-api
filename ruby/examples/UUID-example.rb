##including required libraries
require 'rubygems'
require './lib/pubnub.rb'
require 'securerandom'

puts('Creating UUID String')

##declaring publish_key, subscribe_key, secret_key, message

publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = ''
message    ='hello from ruby'
ssl_on        = !!ARGV[4]

## Create Pubnub Client API (INITIALIZATION)

puts('Creating new Pubnub Client API')
UniqueString=Pubnub.new(publish_key,subscribe_key,secret_key,ssl_on=false)
      
##function for UUID generation
      
uuid=UniqueString.UUID()  #calling the uuid fun
puts("UUID string is --> ",uuid)



