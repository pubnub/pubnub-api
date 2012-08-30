--[[
* The MIT License
* Copyright (C) 2012 Matthew Smith <matthew@rapidfirestudio.com>.  
* All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require "pubnub"

MOAISim.openWindow ( "pubnub-test", 320, 480 )

MOAIGfxDevice.setClearColor ( 1, 1, 1, 1 )

--
-- GET YOUR PUBNUB KEYS HERE:
-- http://www.pubnub.com/account#api-keys
--
pn = pubnub.new ( {
    publish_key   = "demo",             -- YOUR PUBLISH KEY
    subscribe_key = "demo",             -- YOUR SUBSCRIBE KEY
    secret_key    = nil,                -- YOUR SECRET KEY
    ssl           = nil,                -- ENABLE SSL?
    origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
} )

--
-- PUBNUB PUBLISH MESSAGE (SEND A MESSAGE)
--
pn:publish ( {
    channel  = "lua-moai-demo-channel",
    message  = { "1234", 2, 3, 4 },
    callback = function ( info )

        -- WAS MESSAGE DELIVERED?
        if info[1] then
            print ( "MESSAGE DELIVERED SUCCESSFULLY!" )
        else
            print ( "MESSAGE FAILED BECAUSE -> " .. info[2] )
        end

    end
} )

--
-- PUBNUB SUBSCRIBE CHANNEL (RECEIVE MESSAGES)
--
pn:subscribe ( {
    channel  = "lua-moai-demo-channel",
    callback = function ( message )
        -- MESSAGE RECEIVED!!!
        print ( MOAIJsonParser.encode ( message ) )
    end,
    errorback = function()
        print ( "Network Connection Lost" )
    end
} )

--
-- PUBNUB UN-SUBSCRIBE CHANNEL (STOP RECEIVING MESSAGES)
--
pn:unsubscribe ( {
    channel = "lua-moai-demo-channel"
} )

--
-- PUBNUB LOAD MESSAGE HISTORY
--
pn:history ( {
    channel  = "lua-moai-demo-channel",
    limit    = 10,
    callback = function ( messages )
        if not messages then
            return print ( "ERROR LOADING HISTORY" )
        end

        -- NO HISTORY?
        if not ( #messages > 0 ) then
            return print ( "NO HISTORY YET" )
        end

        -- LOOP THROUGH MESSAGE HISTORY
        for i, message in ipairs ( messages ) do
            print ( MOAIJsonParser.encode ( message ) )
        end
    end
} )


--
-- PUBNUB SERVER TIME
--
pn:time ( {
    callback = function ( time )
        -- PRINT TIME
        print ( "PUBNUB SERVER TIME: " .. time )
    end
} )

--
-- PUBNUB UUID
--
uuid = pn:UUID ()
print ( "PUBNUB UUID: ", uuid )
