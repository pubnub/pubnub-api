require "pubnub"

multiplayer = pubnub.new({
    --publish_key   = "pub-e1a3fb60-0952-4ec1-8906-52f10f868cf3",
    --subscribe_key = "sub-24d15ae3-ebcb-11df-8fb9-1b433f1beafd",
    --secret_key    = "sec-c01e7cc7-039a-4e07-8fdb-3af527c9f45a",
    publish_key   = "demo",
    subscribe_key = "demo",
    secret_key    = nil,
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

multiplayer:subscribe({
    channel  = "hello-world-corona",
    callback = function(message)
        print(message.msgtext)
    end,
    errorback = function()
        print("Oh no!!! Dropped 3G Conection!")
    end
})

function send_a_message(text)
    multiplayer:publish({
        channel = "hello-world-corona",
        message = { msgtext = text }
    })
end

function send_hello_world()
    send_a_message("Hello World!!!")
end

timer.performWithDelay( 500, send_hello_world, 10 )

send_hello_world()
