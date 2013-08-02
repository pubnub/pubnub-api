--
-- INIT MULTIPLAYER:
-- This initializes the multiplayer networking layer.
--
require "pubnub"
require "PubnubUtil"

textout = PubnubUtil.textout

multiplayer = pubnub.new({
    publish_key   = "demo",
    subscribe_key = "demo",
    secret_key    = nil,
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

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
