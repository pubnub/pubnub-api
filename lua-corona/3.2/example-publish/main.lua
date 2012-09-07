--
-- PubNub 3.1 : Publish Example
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
