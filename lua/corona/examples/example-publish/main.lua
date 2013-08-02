--
-- PubNub 3.1 : Publish Example
--

require "pubnub"
require "PubnubUtil"

textout = PubnubUtil.textout

--
-- INITIALIZE PUBNUB STATE
--
pubnub_obj = pubnub.new({
    publish_key   = "demo",
    subscribe_key = "demo",
    secret_key    = nil,
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

-- 
-- HIDE STATUS BAR
-- 
display.setStatusBar( display.HiddenStatusBar )

-- 
-- CALL PUBLISH FUNCTION
--
function publish(channel, text)
    pubnub_obj:publish({
        channel = channel,
        message = text,
        callback = function(response)
            textout( response[1] )
            textout( response[2] )
            textout( response[3] )
        end
    })
end

-- 
-- MAIN TEST
-- 
local my_channel = 'hello-corona-demo-channel'

--
-- Publish String
--
publish(my_channel, 'Hello World!' )

--
-- Publish Dictionary Object
--
publish(my_channel, { Name = 'John', Age = '25' })

--
-- Publish Array
--
publish(my_channel, { 'Sunday', 'Monday', 'Tuesday' })
