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
