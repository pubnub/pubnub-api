--
-- PubNub 3.3 : History Example
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
-- CALL HISTORY FUNCTION
--
function detailedHistory(channel, count, reverse)
    pubnub_obj:detailedHistory({
        channel = channel,
        count = count,
        reverse = reverse,
        callback = function(response)

            if response then
                for k, v in pairs(response[1])
                    do 
                    print( type (v) )
                    if (type (v) == 'string')
                    then print(v)
                    elseif (type (v) == 'table') 
                    then
                        for i,line in ipairs(v) do
                            print(line)
                        end
                    end
                end
            end
            
        end
    })
end

-- 
-- MAIN TEST
-- 
local my_channel = 'hello_world'
detailedHistory( my_channel, 5, false )
