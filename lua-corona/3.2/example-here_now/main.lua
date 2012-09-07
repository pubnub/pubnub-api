--
-- PubNub 3.1 : Here Now Example
--
package.path = package.path .. ";.."
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
-- CALL HERE NOW FUNCTION
--
function here_now(channel)
    pubnub_obj:here_now({
        channel = channel,
        limit = limit,
        callback = function(response)
            if response then
                for k, v in pairs(response) 
                    do 
                    if (type (v) == 'string')
                    then textout(v)
                    elseif (type (v) == 'table') 
                    then
                        for i,line in ipairs(v) do
                            textout(line)
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
local my_channel = 'hello-corona-demo-channel'
here_now( my_channel )
