## -----------------------------------
## PubNub Ruby API UUID Example
## -----------------------------------

## including required libraries
require 'rubygems'
require 'pubnub_ruby/pubnub'

## Generating UUID String
pubnub=Pubnub.new("","","","",false)

## calling function for UUID generation
puts('Generating UUID String with UUID() Function')
uuid=pubnub.UUID()
puts('UUID: '+uuid)
