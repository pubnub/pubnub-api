--
-- PubNub 3.1 : UUID Example
--
require "pubnub"
require "crypto"
require "PubnubUtil"

textout = PubnubUtil.textout
--
-- INITIALIZE PUBNUB STATE
--
pubnub_obj = pubnub.new({
    publish_key   = "",
    subscribe_key = "",
    secret_key    = "",
    ssl           = nil,
    origin        = ""
})

-- 
-- HIDE STATUS BAR
-- 
display.setStatusBar( display.HiddenStatusBar )

-- 
-- MAIN TEST
-- 
local uuid = pubnub_obj:UUID()
textout("UUID")
textout(uuid)
