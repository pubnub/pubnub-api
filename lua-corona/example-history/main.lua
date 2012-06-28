--
-- PubNub 3.1 : History Example
--

require "pubnub"

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
-- TEXT OUT - Quick Print
-- 
local textoutline = 1
local function textout( text )
    
    if textoutline > 24 then textoutline = 1 end
    if textoutline == 1 then
        local background = display.newRect(
            0, 0,
            display.contentWidth,
            display.contentHeight
        )
        background:setFillColor(254,254,254)
    end

    local myText = display.newText( text, 0, 0, nil, display.contentWidth/23 )

    myText:setTextColor(200,200,180)
    myText.x = math.floor(display.contentWidth/2)
    myText.y = (display.contentWidth/19) * textoutline - 5

    textoutline = textoutline + 1
    print(text)
end

-- 
-- HIDE STATUS BAR
-- 
display.setStatusBar( display.HiddenStatusBar )

-- 
-- CALL HISTORY FUNCTION
--
function history(channel, limit)
    pubnub_obj:history({
        channel = channel,
        limit = limit,
        callback = function(response)
            if response then
                for k, v in pairs(response) 
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
            
            print(' LOOP THROUGH MESSAGE HISTORY ::::: ')
            
            -- LOOP THROUGH MESSAGE HISTORY
            for i, message in ipairs(messages) do
                print(Json.Encode(message))
            end
        end
    })
end

-- 
-- MAIN TEST
-- 
local my_channel = 'hello-corona-demo-channel'
history( my_channel, 3 )
