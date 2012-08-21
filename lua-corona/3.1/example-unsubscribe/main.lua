--
-- INIT MULTIPLAYER:
-- This initializes the multiplayer networking layer.
--
require "pubnub"
multiplayer = pubnub.new({
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


function connect()
    multiplayer:subscribe({
        channel  = "hello-world-corona",
        connect  = function()
            textout('Connected!')
            send_a_message("Hello World!!!")
        end,
        callback = function(message)
            textout(message.msgtext)
            disconnect()
            timer.performWithDelay( 500, connect )
        end,
        errorback = function()
            textout("Oh no!!! Dropped 3G Conection!")
        end
    })
end

function disconnect()
    multiplayer:unsubscribe({
        channel  = "hello-world-corona",
    })
    textout('Disconnected!')
end

function send_a_message(text)
    multiplayer:publish({
        channel  = "hello-world-corona",
        message  = { msgtext = text },
        callback = function(info)
        end
    })
end

function send_hello_world()
    send_a_message("Hello World!!!")
end

connect()
