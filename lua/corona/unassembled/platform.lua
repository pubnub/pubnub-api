
function pubnub.new(init)
    local self          = pubnub.base(init)
    local subscriptions = {}

    function self:_request(args)
        -- APPEND PUBNUB CLOUD ORIGIN 
        table.insert( args.request, 1, self.origin )

        local url = table.concat( args.request, "/" )

        urlParams = ""
        urlSep = "?"

        if args.query and # args.query then
            for k,v in pairs(args.query) do
                urlParams = urlParams .. urlSep .. k .. "=" .. v
                urlSep = "&"
            end
            url = url .. urlParams
        end

        local params = {}
        params["V"] = "VERSION"
        params["User-Agent"] = "PLATFORM"

        network.request( url, "GET", function(event)
            if (event.isError) then
                return args.callback(nil)
            end

            status, message = pcall( Json.Decode, event.response )

            if status then
                return args.callback(message)
            else
                return args.callback(nil)
            end
        end, params)
    end

    -- RETURN NEW PUBNUB OBJECT
    return self

end
