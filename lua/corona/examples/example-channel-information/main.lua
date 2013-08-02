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
-- Player ID (Generated Later)
-- 
me      = {}
me.id   = nil
me.name = "John Smith"

--
-- Generate Player ID
--
multiplayer:time({
    callback = function(time)
        me.id = time .. '-' .. math.random( 1, 999999 )
    end
})

-- 
-- Players Per Channel
-- 
players_per_game_room = {
    game_room_1234 = {},
    game_room_5678 = {}
}

game_room_1234 = "game_room_1234"

-- 
-- Join Game Room 1234
-- 
multiplayer:subscribe({
    channel  = game_room_1234,
    callback = function(message)

        -- 
        -- Ping? then Pong!
        -- This sends a message from all players, to all players.
        -- This lets you know who and how many players are on a channel.
        -- 
        if message.action == "ping" then
            multiplayer:publish({
                channel = game_room_1234,
                message = {
                    action  = "pong",
                    id      = me.id,
                    name    = me.name
                }
            })

        -- 
        -- Collect Live Players who are in this Game Room.
        -- 
        elseif message.action == "pong" then
            players_per_game_room[game_room_1234][message.id] = message

        -- 
        -- Some Other Game Event
        -- 
        elseif message.action == "something-else" then
            
        end
    end
})


-- 
-- Request Info About Connected Players
-- 
multiplayer:publish({
    channel = game_room_1234,
    message = { action = "ping" }
})

-- 
-- Print info on Game Room 1234
-- 
function wait_for_info_from_players()
    --
    -- Print Number of Players
    --
    print("Number of Players in channel: " .. game_room_1234)
    print(#players_per_game_room[game_room_1234])

    --
    -- Print Info about Each Player
    --
    for player_id, player in pairs(players_per_game_room[game_room_1234]) do
        print("Player: " .. player_id .. "'s Name is " .. player.name)
    end
end

-- 
-- Wait at 1 to 3 seconds for player response
-- before we assume we've received messages from everyone.
-- 
timer.performWithDelay( 2000, wait_for_info_from_players )
