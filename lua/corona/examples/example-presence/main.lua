--
-- PubNub 3.1 : Presence Example
--
require "PubnubUtil"
require "pubnub"
require "table"

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

local textout = PubnubUtil.textout

-- 
-- STARTING WELCOME MESSAGE FOR THIS EXAMPLE
-- 
textout("...")
textout(" ")

-- 
-- HIDE STATUS BAR
-- 
display.setStatusBar( display.HiddenStatusBar )

-- 
-- FUNCTIONS USED FOR TEST
-- 
function presence( channel, donecb )
    pubnub_obj:presence({
        channel = channel,
        connect = function()
            textout('Connected to channel ')
            textout(channel)
        end,
        callback = function(message)
            for i,v in pairs(message) do textout(i .. " " .. v) end
            timer.performWithDelay( 500, donecb )
        end,
        errorback = function()
            textout("Oh no!!! Dropped 3G Conection!")
        end
    })
end

-- 
-- MAIN TEST
-- 
local my_channel = 'hello_world'
presence(my_channel, function() end)
