--
-- PubNub 3.1 : Presence Example
--

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
