-- Project: MultiDrum
-- Description: A multiplayer drum kit
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright © 2011 Raphael Salgado for BeyondtheTech. All Rights Reserved.
---- cpmgen main.lua

require "ui"
require "pubnub"

drumpad = {}
received = {}
soundlabel = { "BD", "SD", "CH", "OH", "CP", "HT", "MT", "LT", "CY", "MA", "CB", "CL", "HC", "MC", "LC", "RS", "switch" }
soundeffect = { }
sendevents = true

display.setStatusBar(display.HiddenStatusBar)
math.randomseed (os.time())
system.activate( "multitouch" )

-- initialize pubnub
multiplayer = pubnub.new ({
    publish_key = "demo",
    subscribe_key = "demo",
    secret_key = "",
    ssl = nil,
    origin = "pubsub.pubnub.com" })


    
-- create a unique drummer ID
my_id = crypto.digest( crypto.md4, system.getInfo("deviceID"))


-- set up interface
header = display.newImageRect ( "header.png", 320, 80 )
header.x = 160
header.y = 40
transition.from ( header, { time = 1000, delay = 1000, y = -80 } )

footer = display.newImageRect ( "footer.png", 320, 80 )
footer.x = 160
footer.y = 440
transition.from ( footer, { time = 1000, delay = 1000, y = 600 } )

statustext = display.newText ( "Connecting to network...", 0, 0, "Helvetica-Bold", 16 )
statustext.x = 160
statustext.y = 380
transition.from ( statustext, { time = 500, x = -160 } )

function switch_handler ( event )
    if event.phase == "ended" then
        if sendevents then
            offswitch.alpha = 1; onswitch.alpha = 0
        else
            offswitch.alpha = 0; onswitch.alpha = 1
        end
        sendevents = not sendevents
        audio.play ( soundeffect[17] )
    end
end

offswitch = display.newImageRect ( "off.png", 60, 60 )
offswitch.x = 265
offswitch.y = 445
offswitch.alpha = 0
offswitch:addEventListener ( "touch", switch_handler )

onswitch = display.newImageRect ( "on.png", 60, 60 )
onswitch.x = 265
onswitch.y = 445
onswitch.alpha = 1
onswitch:addEventListener ( "touch", switch_handler )

transition.from ( offswitch, { delay = 2000, time = 1000, xScale = 0.05, yScale = 0.05 } )
transition.from ( onswitch, { delay = 2000, time = 1000, xScale = 0.05, yScale = 0.05 } )


-- handle pads
function button_handler ( event )
    if event.phase == "press" then
        i = event.id
        audio.play ( soundeffect[i] )
        if sendevents then send_pad (i) end
    end
end


-- load sound effects
for i = 1, #soundlabel do
    soundeffect[i] = audio.loadSound ( soundlabel[i] .. ".caf" );
end


-- draw pads
i = 1
for y = 1, 4 do
    for x = 1, 4 do
        drumpad [i] = ui.newButton {
        defaultSrc = "pad_normal.png", defaultX = 64, defaultY = 64,
        overSrc = "pad_tapped.png", overX = 72, overY = 72,
        onEvent = button_handler,
        text = soundlabel[i],
        id = i
        }
        drumpad [i].x = x * 72 - 16
        drumpad [i].y = 40 + ( y * 72 )
        transition.from (drumpad[i], {
            time = 1000,
            xScale = 0.1, yScale = 0.1,
            x = math.random(-160,480), y = math.random(-160,640),
            rotation = math.random(-360,360),
            transition = easing.inOutExpo } )
        received [i] = display.newImageRect ( "pad_received.png", 72, 72 )
        received [i].x = x * 72 - 16
        received [i].y = 40 + ( y * 72 )
        received [i].alpha = 1
        received [i].fade = transition.to ( received [i], { time = 50, alpha = 0 } )
        i = i + 1
    end
end


-- get the server time
multiplayer:time({
    callback = function(time)
        -- get the time to the nearest second
        servertime = time
        if servertime ~= nil then
            -- create a unique session room
            session = math.ceil ( servertime * 0.000000005 )
            statustext.text = "Online Session #" .. session
            start_listening()
            send_hello()
        end
    end
})


-- listen for pad events
function start_listening()
    multiplayer:subscribe ({
        channel = session,
        callback = function ( message )
            if message.action and message.id then 
                -- don't listen to my own messages
                if message.id ~= my_id then
                    if message.action == "play" and message.id ~= my_id then
                        i = message.padnumber
                        audio.play ( soundeffect[i] )
                        transition.cancel (received [i].fade)
                        received [i].alpha = 1
                        received [i].fade = transition.to ( received [i], { time = 100, alpha = 0 } )
                    elseif message.action == "hello" and message.id ~= my_id then
                        statustext.text = "New multidrummer entered the session."
                    elseif message.action == "goodbye" and message.id ~= my_id then
                        statustext.text = "A multidrummer has left the session."
                    end
                end
            end
        end,
        errorback = function ()
            statustext.text = "Network receive error"
        end
    })
end


-- send pad event
function send_pad ( my_padnumber )
    multiplayer:publish ({
        channel = session,
        message = {
            id = my_id,
            action = "play",
            padnumber = my_padnumber
        },
        callback = function(info)
            if info[1] then
                -- sent successfully
                print ( "Pad sent!")
            else
                statustext.text = "Network send error"
            end
        end
    })
end


-- send hello to session
function send_hello ()
    multiplayer:publish ({
        channel = session,
        message = {
            id = my_id,
            action = "hello",
        },
        callback = function(info)
            if info[1] then
                -- sent successfully
                print ( "Hello sent!")
            else
                statustext.text = "Network send error"
            end
        end
    })
end

