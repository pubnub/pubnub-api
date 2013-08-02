-- www.pubnub.com - PubNub realtime push service in the cloud.
-- https://github.com/pubnub/pubnub-api/tree/master/lua lua-Corona Push API

-- PubNub Real Time Push APIs and Notifications Framework
-- Copyright (c) 2010 Stephen Blum
-- http://www.pubnub.com/

-- -----------------------------------
-- PubNub VERSION Real-time Push Cloud API
-- -----------------------------------

require "Json"
require "crypto"
require "BinDecHex"
pubnub      = {}

function pubnub.base(init)
    local self          = init
    local subscriptions = {}

    -- SSL ENABLED?
    if self.ssl then 
        self.origin = "https://" .. self.origin
    else
        self.origin = "http://" .. self.origin
    end

    function self:publish(args)
        local callback = args.callback or function() end

        if not (args.channel and args.message) then
            return callback({ nil, "Missing Channel and/or Message" })
        end

        local channel   = args.channel
        local message   = Json.Encode(args.message)
        local signature = "0"

        -- SIGN PUBLISHED MESSAGE?
        if self.secret_key then
            signature = crypto.hmac( crypto.sha256,self.secret_key, table.concat( {
                self.publish_key,
                self.subscribe_key,
                self.secret_key,
                channel,
                message
            }, "/" ) )
        end

        -- PUBLISH MESSAGE
        self:_request({
            callback = function(response)
                if not response then
                    return callback({ nil, "Connection Lost" })
                end
                callback(response)
            end,
            request  = {
                "publish",
                self.publish_key,
                self.subscribe_key,
                signature,
                self:_encode(channel),
                "0",
                self:_encode(message)
            }
        })
    end

    function self:subscribe(args)
        local channel   = args.channel
        local callback  = callback or args.callback
        local errorback = args['errorback'] or function() end
        local connectcb = args['connect'] or function() end
        local timetoken = 0

        if not channel then return print("Missing Channel") end
        if not callback then return print("Missing Callback") end

        -- NEW CHANNEL?
        if not subscriptions[channel] then
            subscriptions[channel] = {}
        end

        -- ENSURE SINGLE CONNECTION
        if (subscriptions[channel].connected) then
            return print("Already Connected")
        end

        subscriptions[channel].connected = 1
        subscriptions[channel].first     = nil

        -- SUBSCRIPTION RECURSION 
        local function substabizel()
            -- STOP CONNECTION?
            if not subscriptions[channel].connected then return end

            -- CONNECT TO PUBNUB SUBSCRIBE SERVERS
            self:_request({
                callback = function(response)
                    -- STOP CONNECTION?
                    if not subscriptions[channel].connected then return end

                    -- CONNECTED CALLBACK
                    if not subscriptions[channel].first then
                        subscriptions[channel].first = true
                        connectcb()
                    end

                    -- PROBLEM?
                    if not response then
                        -- ENSURE CONNECTED
                        return self:time({
                            callback = function(time)
                                if not time then
                                    timer.performWithDelay( 1000, substabizel )
                                    return errorback("Lost Network Connection")
                                end
                                timer.performWithDelay( 10, substabizel )
                            end
                        })
                    end

                    timetoken = response[2]
                    timer.performWithDelay( 1, substabizel )

                    for i, message in ipairs(response[1]) do
                        callback(message)
                    end
                end,
                request = {
                    "subscribe",
                    self.subscribe_key,
                    self:_encode(channel),
                    "0",
                    timetoken
                },
                query = { uuid = self.uuid }
            })
        end

        -- BEGIN SUBSCRIPTION (LISTEN FOR MESSAGES)
        substabizel()
        
    end

    function self:unsubscribe(args)
        local channel = args.channel
        if not subscriptions[channel] then return nil end

        -- DISCONNECT
        subscriptions[channel].connected = nil
        subscriptions[channel].first     = nil
    end

    function self:presence(args)
	args.channel = args.channel .. '-pnpres'
	self:subscribe(args)
    end

    function self:here_now(args)
        if not (args.callback and args.channel) then
            return print("Missing Here Now Callback and/or Channel")
        end

        local channel  = args.channel
        local callback = args.callback

        self:_request({
            callback = callback,
            request  = {
                'v2',
                'presence',
                'sub-key', self.subscribe_key,
                'channel', self:_encode(channel)
            }
        })

    end    

    function self:history(args)
        if not (args.callback and args.channel) then
            return print("Missing History Callback and/or Channel")
        end

        local limit    = args.limit
        local channel  = args.channel
        local callback = args.callback

        if not limit then limit = 10 end

        self:_request({
            callback = callback,
            request  = {
                'history',
                self.subscribe_key,
                self:_encode(channel),
                '0',
                limit
            }
        })
    end

    function self:detailedHistory(args)
        if not (args.callback and args.channel) then
            return print("Missing History Callback and/or Channel")
        end

        query = {}

        if (args.start or args.stop or args.reverse) then

            if args.start then
                query["start"] = args.start
            end

            if args.stop then
                query["stop"] = args.stop
            end

            if args.reverse then
                if (args.reverse == true or args.reverse == "true") then
                    query["reverse"] = "true"
                    else
                    query["reverse"] = "false"
                end
            end
        end

        local channel  = args.channel
        local callback = args.callback
        local count = args.count

        if not count then
            count = 10
            else count = args.count
        end

        query["count"] = count

        self:_request({
            callback = callback,
            request  = {
                'v2',
                'history',
                'sub-key',
                self.subscribe_key,
                'channel',
                self:_encode(channel)
            },
            query = query
        })
    end

    function self:time(args)
        if not args.callback then
            return print("Missing Time Callback")
        end

        self:_request({
            request  = { "time", "0" },
            callback = function(response)
                if response then
                    return args.callback(response[1])
                end
                args.callback(nil)
            end
        })
    end

    function self:_encode(str)
        str = string.gsub( str, "([^%w])", function(c)
            return string.format( "%%%02X", string.byte(c) )
        end )
        return str
    end

    function self:_map( func, array )
        local new_array = {}
        for i,v in ipairs(array) do
            new_array[i] = func(v)
        end
        return new_array
    end

     local Hex2Dec, BMOr, BMAnd, Dec2Hex
     if(BinDecHex)then
        Hex2Dec, BMOr, BMAnd, Dec2Hex = BinDecHex.Hex2Dec, BinDecHex.BMOr, BinDecHex.BMAnd, BinDecHex.Dec2Hex
     end

     function self:UUID()
        local chars = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
        local uuid = {[9]="-",[14]="-",[15]="4",[19]="-",[24]="-"}
        local r, index
        for i = 1,36 do
                if(uuid[i]==nil)then
                        -- r = 0 | Math.random()*16;
                        r = math.random (36)
                        if(i == 20 and BinDecHex)then 
                                -- (r & 0x3) | 0x8
                                index = tonumber(Hex2Dec(BMOr(BMAnd(Dec2Hex(r), Dec2Hex(3)), Dec2Hex(8))))
                                if(index < 1 or index > 36)then 
                                        print("WARNING Index-19:",index)
                                        return UUID() -- should never happen - just try again if it does ;-)
                                end
                        else
                                index = r
                        end
                        uuid[i] = chars[index]
                end
        end
        return table.concat(uuid)
     end

    self.uuid = self:UUID()
    
    -- RETURN NEW PUBNUB OBJECT
    return self

end
