## -----------------------------------
## PubNub Ruby API UUID Example
## -----------------------------------

## including required libraries
require 'rubygems'
require 'eventmachine'
require './lib/pubnub.rb'
require 'securerandom'

## Generating UUID String
puts('Generating UUID String')
pubnub=Pubnub.new("","","","",false)

## calling function for UUID generation
uuid=pubnub.UUID()
puts('UUID: '+uuid)
