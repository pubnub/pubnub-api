## PubNub 3.3 Real-time Cloud Push API - Corona
## www.pubnub.com - PubNub Real-time Push Service in the Cloud. 

###GET YOUR PUBNUB KEYS HERE:
###http://www.pubnub.com/account#api-keys

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

#### Be sure to copy "pubnub.lua" and "Json.lua" into your Project Directory. Check out the examples in the 3.2 directory for complete code examples.

Require "pubnub"

multiplayer = pubnub.new({
    publish_key   = "demo",             -- YOUR PUBLISH KEY
    subscribe_key = "demo",             -- YOUR SUBSCRIBE KEY
    secret_key    = nil,                -- YOUR SECRET KEY
    ssl           = nil,                -- ENABLE SSL?
    origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})

### PUBLISH

multiplayer:publish({
    channel  = "lua-corona-demo-channel",
    message  = { "1234", 2, 3, 4 },
    callback = function(info)

        -- WAS MESSAGE DELIVERED?
        if info[1] then
            print("MESSAGE DELIVERED SUCCESSFULLY!")
        else
            print("MESSAGE FAILED BECAUSE -> " .. info[2])
        end

    end
})

### SUBSCRIBE

multiplayer:subscribe({
    channel  = "lua-corona-demo-channel",
    callback = function(message)
        -- MESSAGE RECEIVED!!!
        print(Json.Encode(message))
    end,
    errorback = function()
        print("Network Connection Lost")
    end
})


### UN-SUBSCRIBE

multiplayer:unsubscribe({
    channel = "lua-corona-demo-channel"
})


### HISTORY (Deprecated, use detailedHistory)

multiplayer:history({
    channel  = "lua-corona-demo-channel",
    limit    = 10,
    callback = function(messages)
        if not messages then
            return print("ERROR LOADING HISTORY")
        end

        -- NO HISTORY?
        if not (#messages > 0) then
            return print("NO HISTORY YET")
        end

        -- LOOP THROUGH MESSAGE HISTORY
        for i, message in ipairs(messages) do
            print(Json.Encode(message))
        end
    end
})

### Detailed History

function detailedHistory(channel, count, reverse)
    pubnub_obj:detailedHistory({
        channel = channel,
        count = count,
        reverse = reverse,
        callback = function(response)
            if response then
                for k, v in pairs(response[1])
                    do
                    print( type (v) )
                    if (type (v) == 'string')
                    then print(v)
                    elseif (type (v) == 'table')
                    then
                        for i,line in ipairs(v) do
                            print(line)
                        end
                    end
                end
            end

        end
    })
end

local my_channel = 'hello_world'
detailedHistory( my_channel, 5, false )

###PUBNUB SERVER TIME

multiplayer:time({
    callback = function(time)
        -- PRINT TIME
        print("PUBNUB SERVER TIME: " .. time)
    end
})

###PUBNUB UUID

uuid = multiplayer:UUID()
print("PUBNUB UUID: ", uuid)


### here_now

function here_now(channel)
    pubnub_obj:here_now({
        channel = channel,
        limit = limit,
        callback = function(response)
            if response then
                for k, v in pairs(response) 
                    do 
                    if (type (v) == 'string')
                    then textout(v)
                    elseif (type (v) == 'table') 
                    then
                        for i,line in ipairs(v) do
                            textout(line)
                        end
                    end
                end
            end
        end
    })
end

local my_channel = 'hello-corona-demo-channel'
here_now( my_channel )

### Presence

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

local my_channel = 'hello_world'
presence(my_channel, function() end)

