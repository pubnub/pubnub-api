
require "pubnub"
require "crypto"

multiplayer = pubnub.new({
    publish_key   = "demo",
    subscribe_key = "demo",
    secret_key    = "demo",
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

local uuid = multiplayer:UUID()
print("UUID - " ,uuid)

