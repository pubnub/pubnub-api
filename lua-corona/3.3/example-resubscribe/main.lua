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

-- 
-- FUNCTIONS USED FOR TEST
-- 
function connect( channel, donecb )
    multiplayer:subscribe({
        channel = channel,
        connect = function()
            textout('Connected!')
            send_a_message( "Hello World!!!", channel )
        end,
        callback = function(message)
            textout(message.msgtext)
            disconnect(channel)
            timer.performWithDelay( 500, donecb )
        end,
        errorback = function()
            textout("Oh no!!! Dropped 3G Conection!")
        end
    })
end

function disconnect(channel)
    multiplayer:unsubscribe({
        channel = channel,
    })
    textout( 'Disconnected from ' .. channel )
end

function send_a_message( text, channel )
    multiplayer:publish({
        channel  = channel,
        message  = { msgtext = text }
    })
end

-- 
-- MAIN TEST
-- 
connect(
    'x',
    function()

        connect(
            'y',
            function()
                
                connect(
                    'x',
                    function()
                        textout('done')
                    end --x
                ) -- x

            end -- y
        ) -- y

    end -- x
) -- x
