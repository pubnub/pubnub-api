

function pubnub.new( init )

    local self          = pubnub.base(init)

	function self:performWithDelay ( delay, func, ... )
		local t = MOAITimer.new()
		t:setSpan ( delay )
		t:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function ()
			t:stop ()
			t = nil
			func ( unpack ( arg ) )
		end )
		t:start ()
	end

    function self:_request ( args )
    
        -- APPEND PUBNUB CLOUD ORIGIN 
        table.insert ( args.request, 1, self.origin )

        local url = table.concat ( args.request, "/" )
		
		print ( url )

		local task = MOAIHttpTask.new ()
		task:setHeader 		( "V", "VERSION" )
		task:setHeader 		( "User-Agent", "PLATFORM" )
		task:setUrl 		( url )
		task:setCallback	( function ( response )	
		
			if response.code then -- this appears to return no code if no error, need to check more
				return args.callback ( nil )
			end
			status, message = pcall ( MOAIJsonParser.decode, response:getString () )
			
			if status then
                return args.callback ( message )
            else
                return args.callback ( nil )
            end
			
		end )
		
		task:performAsync ()
    end

    -- RETURN NEW PUBNUB OBJECT
    return self
end
