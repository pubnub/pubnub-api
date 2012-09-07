--
-- INIT MULTIPLAYER:
-- This initializes the multiplayer networking layer.
--
require "pubnub"
multiplayer = pubnub.new({
    publish_key   = "demo",             -- YOUR PUBLISH KEY
    subscribe_key = "demo",             -- YOUR SUBSCRIBE KEY
    secret_key    = nil,                -- YOUR SECRET KEY
    ssl           = nil,                -- ENABLE SSL?
    origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})

-- 
-- TEXT OUT - Quick Print
-- 
local textoutline = 1
local function textout( text )

    if textoutline > 24 then textoutline = 1 end
    if textoutline == 1 then
        local background = display.newRect(
            0, 0,
            display.contentWidth,
            display.contentHeight
        )
        background:setFillColor(254,254,254)
    end

    local myText = display.newText( text, 0, 0, nil, display.contentWidth/23 )

    myText:setTextColor(200,200,180)
    myText.x = math.floor(display.contentWidth/2)
    myText.y = (display.contentWidth/19) * textoutline - 5

    textoutline = textoutline + 1
end

-- 
-- STARTING WELCOME MESSAGE FOR THIS EXAMPLE
-- 
textout("Welcome to the Example Game Lobby Room.")
textout("This is not a full game lobby room.")
textout("You must use the data exchanged between")
textout("users to construct a list of games.")
textout("Make sure to read the source code!")
textout(" ")

-- 
-- HIDE STATUS BAR
-- 
display.setStatusBar( display.HiddenStatusBar )
 
--
-- ONLINE PLAYERS TABLE (IN LOBBY ROOM)
--
players_in_lobby = {}
 
--
-- ACTIVE GAMES TABLE
--
games_in_lobby = {}
 
--
-- LOCAL PLAYER DETAILS
-- This is the current player of the device.
-- For example, it will contain Your User Details.
--
my_player = {
    id        = math.random( 1, 9999999 ),  -- MAKE SURE TO SUPPLY REAL ID
    name      = "Johny Player", -- MAKE SURE TO SUPPLY REAL NAME
    level     = 12,
    score     = 4000,
    location  = "San Francisco", -- MAKE SURE TO SUPPLY REAL LOCATION
    game_room = nil -- PLAYING NOBODY YET, NOT IN A ROOM YET.
}
 
--
-- LOCAL GAME DETAILS
-- This table holds info about the local player's game
-- only if the player choses to host a game.
--
my_game = {
    enabled   = false, -- Disabled until Player Clicks "Host Game" Button
    started   = false, -- The game isn't started yet.
    channel   = 'game-room-' .. math.random( 1, 9999999 ), -- GAME ROOM ID
    room_name = my_player.name .. "'s Game" -- Johny Player's Game
}
 
--
-- HOST A NEW GAME
-- A player would CLICK A BUTTON to HOST a game.
--
function host_a_game()
    -- ENABLE HOSTING OF A GAME
    my_game.enabled = true
 
    -- PUBLISH UPDATE TO THE LOBBY ROOM
    publish_my_details()
end
 
--
-- JOIN A NEW GAME
-- A player would CLICK A BUTTON to JOIN a game.
-- The JOIN BUTTON would be associated with a game_room_channel var.
--
function join_a_game(game_room_channel)
    --
    -- SAVE GAME CHANNEL ROOM ID
    --
    my_player.game_room = game_room_channel
 
    --
    -- UNSUBSCRIBE FROM THE GAME LOBBY ROOM CHANNEL
    --
    multiplayer:unsubscribe({
        channel = "game-lobby-room"
    })
 
    --
    -- SUBSCRIBE TO THE GAME ROOM CHANNEL
    --
    multiplayer:subscribe({
        channel  = my_player.game_room,
        callback = function(message)
            if message.action == "start-game" then
                -- !!! --
                -- THE GAME STARTS!!!!
                -- !!! --
            elseif message.action == "game-event-2" then
                -- one of the players did something
            elseif message.action == "game-event-3" then
                -- one of the players did something else
            end
        end,
        errorback = function()
            print("Network Connection Lost")
        end
    })
 
    --
    -- INDICATE TO THE GAME HOST THAT YOU WILL PLAY!
    --
    multiplayer:publish({
        channel = my_player.game_room,
        message = {
            action = "start-game", -- REPLY
            player = my_player     -- SEND MY PLAYER DETAILS
        }
    })
end
 
--
-- SUBMIT YOUR DETAILS TO THE GAME LOBBY ROOM
--
function publish_my_details()
    multiplayer:publish({
        channel = "game-lobby-room",
        callback = function(info) end,
        message = {
            action = "respond-to-call", -- REPLY
            player = my_player, -- SEND MY PLAYER DETAILS
            game   = my_game    -- SEND MY GAME HOSTING DETAILS
        }
    })
end
 
--
-- JOIN GAME LOBBY ROOM CHANNEL
--
multiplayer:subscribe({
    channel  = "game-lobby-room",
    connect  = function()
        textout('CONNECTION ESTABLISHED')
        ready()
    end,
    callback = function(message)
        --textout(message.action)
        --
        -- DO NOTHING IF PLAYER ISN'T READY
        --
        if not my_player.id then return nil end
 
        --
        -- REQUEST FOR PLAYERS IN GAME LOBBY ROOM?
        --
        if message.action == "calling-all-players" then
            --
            -- EVERYONE ANNOUNCES PRESENCE
            -- THIS GIVES EVERYONE IN THE LOBBY A FULL LIST OF PLAYERS
            --
            publish_my_details()
 
        --
        -- RECEIVE RESPONSE FROM ALL PLAYERS IN THE GAME LOBBY ROOM
        --
        elseif message.action == "respond-to-call" then
            --
            -- UPDATE PLAYERS TABLE IN GAME LOBBY 
            --
            players_in_lobby[message.player.id] = message.player

            textout("Player '" .. message.player.id .. "' is here.")
 
            --
            -- UPDATE GAMES TABLE
            -- This list/table will contain all the active games.
            --
            if message.game.enabled then
                games_in_lobby[message.player.id] = message.game
            end
        end
    end,
    errorback = function()
        print("Network Connection Lost")
    end
})
 
--
-- PLAYER IS READY AND HAS A UNIQUE ID
--
function ready()
    --
    -- REQUEST FOR GAME LOBBY ROOM DETAILS
    -- This will invoke the "respond-to-call" elseif switch above
    -- inside the multiplayer:subscribe function.
    --

    multiplayer:time({
        callback = function(time)
            my_player.id = time .. '-' .. math.random( 1, 999999 )
            --
            -- SEND REQUEST FOR LIST OF PLAYERS
            --
            multiplayer:publish({
                channel = "game-lobby-room",
                message = {
                    action = "calling-all-players" -- REQUEST FOR LOBBY DETAILS
                }
            })
        end
    })
end

