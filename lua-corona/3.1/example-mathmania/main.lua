--
-- Project: Mathemania
-- 
-- Short Description: A PubNub Sample Multiplayer Game
-- 
-- Long Description: Mathemania is a multiplayer math-based trivia game that uses the PubNub
-- Multiplayer API in Ansca Mobile Corona SDK.  The game features an auto-hosting capability
-- and plays well in 3G as well as Wi-Fi.
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright © 2011 Raphael Salgado for BeyondtheTech. All Rights Reserved.
-- 
require "pubnub"
require "crypto"
require "ui"

-- main variables
my_player_name = system.getInfo( "name" )
my_player_mode = "guest"
my_player_score = 0
my_player_last_delta = 0
my_player_correct = 0
my_player_wrong = 0
my_player_last_round = "none"
gameroom = "mathemania"
player_roster = {}
player_stats = {}
leaderboard = {}
server_time = nil
game_clock = 0
point_value = 0
value_a = 0; operand_1 = "+"; value_b = 0; operand_2 = "+"; value_c = 0
correct_answer = 0
answer_selection = { }
question_data = {}
round_in_session = false
get_ready = { "Get ready!", "Here it comes!", "Here we go!", "Are you ready?", "Let's do it!", "Bring it on!" }
times_up = { "Time's up!", "Not even a guess?", "Not sure, huh?", "Better luck next time!", "You'll get 'em next round!" }
correct = { "You are correct!", "Exactamundo!", "You got it!", "Alright!", "Brilliant!", "What a brain!", "Great, keep it up!", "Yes, that's it!" }
wrong = { "Sorry, wrong answer!", "Better luck next time!", "So close!", "You are incorrect.", "Oops!", "No, that's not it." }
button = {}
button_text = {}

math.randomseed (os.time())


-- initialize pubnub
multiplayer = pubnub.new ({
    publish_key = "demo",
    subscribe_key = "demo",
    secret_key = "",
    ssl = nil,
    origin = "pubsub.pubnub.com" })


-- create a unique player id, hash the UDID
my_player_id = crypto.digest( crypto.md4, system.getInfo("deviceID"))


-- get the time
function check_server_time()
    multiplayer:time({
    callback = function(time)
        -- get the time to the nearest second
        server_time = time * 0.0000001
        -- first time? synchronize game clock counter and say hello
        if server_time ~= nil then
            game_clock = math.floor(server_time % 25 + 1)
            print ( "(pubnub) received time: " .. server_time .. " > " .. game_clock )
        if game_clock > 14 and game_clock < 22 then send_message ( "rollcall" ) end
            point_value_text.text = "Waiting for next round..."
        end
    end
    })
end


-- resync with server
function resync_server_time()
    multiplayer:time({
    callback = function(time)
        -- get the time to the nearest second
        server_time = time * 0.0000001
        print ( "(pubnub) received time" )
        game_clock = math.floor(server_time % 25 + 1)
    end
    })
end
    
-- start push notification for pubnub
multiplayer:subscribe ({
    channel = gameroom,
    callback = function ( message )
        --print ("(pubnub) received")
        if message.action then 
            -- did anyone call out for a roll call?
            if message.action == "rollcall" then
                if message.player_name == my_player_name then
                    print ("Requesting a roll call")
                else
                    print ("Responding to a roll call by " .. message.player_name )
                end
                send_message ( "present", "Hello!" )
            elseif message.action == "present" then
                print ( message.player_name .. " (" .. message.player_id .. ") is present" )
                if table.indexOf( player_roster , message.player_id ) == nil then
                    table.insert(player_roster, message.player_id )
                    index = table.indexOf( player_roster , message.player_id )
                    player_stats[index] = {}
                    player_stats[index].name = message.player_name
                    player_stats[index].mode = message.player_mode
                    player_stats[index].score = message.player_score
                    player_stats[index].last_delta = message.player_last_delta
                    player_stats[index].correct = message.player_correct
                    player_stats[index].wrong = message.player_wrong
                end
            elseif message.action == "hosting" and message.player_name ~= my_player_name then
                demote_myself()
            elseif message.action == "announcement" then
                print ( message.player_name .. " says " .. message.dialog )
            elseif message.action == "question" then
                if game_clock < 5 or game_clock > 22 then
                    parse_question(message.dialog)
                    start_new_round()
                else
                    point_value_text.text = "Slow network, skipping round."
                    resync_server_time()
                end
            end
        else
            print ("unknown message")
        end
    end,
    errorback = function ()
        print ( "(pubnub) receive error" )
        end
    })
        

-- publish message to pubnub
function send_message ( action, text )
    multiplayer:publish ({
        channel = gameroom,
        message = {
            player_id = my_player_id,
            player_name = my_player_name,
            player_mode = my_player_mode,
            player_score = my_player_score,
            player_last_delta = my_player_last_delta,
            player_correct = my_player_correct,
            player_wrong = my_player_wrong,
            action = action,
            dialog = text
        },
        callback = function(info)
            if info[1] then
                --print ("(pubnub) published")
                -- clear the roster for a new roll call
                if action == "rollcall" then
                    print ("Waiting for all players to respond")
                    player_roster = { }
                    player_stats = { }
                    timer.performWithDelay( 3000, show_player_roster )
                elseif action == "hosting" then
                    my_player_mode = "host"
                    print ( "I am now the host" )
                    title.text = "You're now hosting the room."
                elseif action == "guesting" then
                    my_player_mode = "guest"
                    print ( "I am no longer the host" )
                    title.text = "You are a guest in the room."
                end
            else
                print ("(pubnub) send error: " .. info[2])
            end
    end
    })
end


-- promote myself to host
function promote_myself()
    print ("No game host available, promoting myself")
    send_message ( "hosting" )
end


-- remove myself as host
function demote_myself()
    print ("Multiple game hosts available, demoting myself")
    send_message ( "guesting" )
end


-- get the roster and check for host
function show_player_roster()
    host_count = 0
    print ( "Number of players in room: " .. #player_stats )
    for i=1, #player_stats do
        -- print("#" .. i .. ". " .. player_stats[i].name .. " (" .. player_stats[i].mode .. ")")
        if player_stats[i].mode == "host" then
            host_count = host_count + 1
        end
    end
    if host_count == 0 then
        promote_myself()
    elseif host_count > 1 then
        demote_myself()
    end
end


-- shuffle answers
function shuffle( array )
    array2 = {}
    for i=1, #array do
        index = math.random(#array)
        grabbed_value = array[index]
        table.remove(array, index)
        array2[i] = grabbed_value
    end
    return array2
end


-- generate new math question
function generate_new_question()
    value_a = math.random(1,99)
    value_b = math.random(1,99)
    if math.random(2) ==1 then value_c = 0 else value_c = math.random(1,99) end
    if math.random(2) == 1 then operand_1 = "+" else operand_1 = "-" end
    if math.random(2) == 1 then operand_2 = "+" else operand_2 = "-" end
    -- compute the equation
    correct_answer = value_a
    if operand_1 == "+" then correct_answer = correct_answer + value_b else correct_answer = correct_answer - value_b end
    if operand_2 == "+" then correct_answer = correct_answer + value_c else correct_answer = correct_answer - value_c end        
    -- create five different choices
    answer_selection[1] = correct_answer - math.random(1,25)
    answer_selection[2] = answer_selection[1] - math.random(1,25)
    answer_selection[3] = correct_answer + math.random(1,25)
    answer_selection[4] = answer_selection[3] + math.random(1,25)
    answer_selection[5] = correct_answer
    --print ( "Choices are: " .. table.concat ( answer_selection, ", ") )
    answer_selection = shuffle (answer_selection)
    --print ( "Shuffled is: " .. table.concat ( answer_selection, ", ") )
    print ( "Correct answer is: " .. correct_answer )
    question_data = value_a .. " " .. operand_1 .. " " .. value_b
    if value_c > 0 then question_data = question_data .. " " .. operand_2 .. " " .. value_c end
    question_data = question_data .. "|" .. correct_answer .. ">"
    for i=1, 5 do
        question_data = question_data .. answer_selection[i] .. " "
    end
    print ( "Issuing new math question" )
    send_message( "question", question_data )
end


-- parse question string
function parse_question( text )
    math_question = string.sub ( text, 1, string.find ( text, "|" ) - 1 )
    print ( "Math question received" )
    answers = string.sub ( text, string.find ( text, ">" ) + 1)
    answer_selection = {}
    for value in string.gmatch(answers, "%S+") do
        answer_selection[ #answer_selection + 1 ] = value
    end
    correct_answer = string.sub ( text, string.find ( text, "|" ) + 1, string.find ( text, ">" ) - 1 ) 
    print ( text )
    print ( correct_answer )
end


-- show correct answer
function show_correct_answer()
    for i=1, 5 do
        if answer_selection[i] ~= correct_answer then
            button_text[i].alpha = 0.15
        end
    end
    old_text = equation_text.text
    equation_text.text = old_text .. " = " .. correct_answer
    transition.to (equation_text, { time = 1000, xScale = 0.45, yScale = 0.9 } )
end


-- reduce point value
function reduce_point_value()
    if round_in_session then
        point_value = point_value - point_reduction
        if point_value <= 0 then
            point_value = 0
            point_value_text.text = times_up[math.random(#times_up)]
            round_in_session = false
            my_player_last_round = "pass"
            show_correct_answer()
        else
            point_value_text.text = "Value: " .. comma_value(math.ceil(point_value))
        end
    end
end
    
        
-- start new round
function start_new_round()
    print ("New round begins")
    title.text = "MATHEMANIA (" .. my_player_mode .. ")"
    if value_c == 0 then point_value = 1000 else point_value = 3000 end
    point_reduction = point_value / 125
    round_in_session = true
    equation_text.text = math_question
    for i=1, 5 do
        button_text[i].text = answer_selection[i]
        button_text[i].alpha = 1
    end
    transition.to ( leaderboard_group, { time = 1000, alpha = 0.1 } )
    reset_equation_graphics()
    -- begin value countdown
    timer.performWithDelay (50, reduce_point_value, 125)
end


-- game clock loop
function game_clock_loop()
    if server_time == nil then
        check_server_time()
    else
        game_clock = game_clock % 25 + 1
        game_clock_text.text = game_clock
        if game_clock == 1 then
            if my_player_mode == "host" then
                generate_new_question()
            end
        elseif game_clock == 5 and point_value == 0 then
            point_value_text.text = "No response from host."
        elseif game_clock == 14 then
            my_player_last_round = "none"
            point_value_text.text = "Updating scores..."
            send_message ( "rollcall" )
        elseif game_clock == 19 then
            transition.to ( equation_text, { time = 1000, alpha = 0.2 } )
            transition.to ( leaderboard_group, { time = 1000, alpha = 1 } )
            point_value_text.text = "Leaderboard"
            show_leaderboard()
        elseif game_clock == 22 then
            point_value_text.text = get_ready[math.random(#get_ready)]
            for i=1, 5 do
                button_text[i].text = ""
            end
        end
    end
    timer.performWithDelay ( 1000, game_clock_loop)
end


-- format number with commas
function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end


-- reset equation graphics
function reset_equation_graphics()
    equation_text.rotation = math.random(-60,60)
    equation_text.xScale = 1
    equation_text.yScale = 2
    equation_text.alpha = 1
    transition.to (equation_text, {time = 2000, rotation = math.random(-20,20), xScale = 0.5, yScale = 1, transition = easing.outExpo})
end


-- flash delta
function flash_delta()
        temp_delta = comma_value(my_player_last_delta)
        if my_player_last_delta > 0 then
            temp_delta = "+" .. temp_delta
        end
    delta_text = display.newText ( temp_delta, 0, 0, "Helvetica-Bold", 48)
    delta_text.x = 160
    function remove_delta()
        delta_text:removeSelf()
        delta_text = nil
    end
    if my_player_last_delta > 0 then
        delta_text:setTextColor (0,255,0)
        delta_text.y = point_value_text.y
        timer.performWithDelay ( 1000, function() your_score_text.text = "Your Score: " .. comma_value( my_player_score ) end)
        transition.to (delta_text, { time = 3000, alpha = 0, y = your_score_text.y, transition = easing.outExpo, onComplete = remove_delta })
    else
        delta_text:setTextColor (255,0,0)
        delta_text.y = your_score_text.y
        your_score_text.text = "Your Score: " .. comma_value( my_player_score )
        transition.to (delta_text, { time = 3000, alpha = 0, y = point_value_text.y, transition = easing.outExpo, onComplete = remove_delta })
    end
end


-- flash correct or wrong symbol
function flash_symbol( symbol_type, x, y )
    symbol = display.newImageRect ( symbol_type, 64, 64 )
    symbol.x = x
    symbol.y = y
    symbol.alpha = 1
    function delete_symbol()
        symbol:removeSelf()
        symbol = nil
    end
    transition.to ( symbol, { delay = 500, time = 1000, xScale = 3, yScale = 3, alpha = 0, onComplete = delete_symbol, transition = easing.inExpo } )
end


-- button handler
function button_handler( event )
    if round_in_session then
        if event.phase == "release" then
            round_in_session = false
            show_correct_answer()
            if answer_selection[ event.id ] == correct_answer then
                my_player_score = my_player_score + point_value
                point_value_text.text = correct[math.random(#correct)]
                flash_symbol( "correct.png", button[event.id].x, button[event.id].y )                
                my_player_last_result = "correct"
                my_player_correct = my_player_correct + 1
            else
                point_value = -point_value
                my_player_score = my_player_score + point_value
                point_value_text.text = wrong[math.random(#wrong)]
                flash_symbol( "wrong.png", button[event.id].x, button[event.id].y )                
                my_player_last_result = "wrong"
                my_player_wrong = my_player_wrong + 1
            end
            my_player_last_delta = point_value
            timer.performWithDelay (2000, flash_delta)
        end
    end
end


-- pad a string
function padded(s, width, padder)
    padder = string.rep(padder or " ", math.abs(width))
    if width < 0 then return string.sub(padder .. s, width) end
    return string.sub(s .. padder, 1, width)
end


-- trim a string from PiL2 20.4
function trimmed(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


-- sort and show the leaderboard
function show_leaderboard()
    temp_leaderboard = {}
    for i=1, #player_stats do
        -- temporarily adjust score so all values are positive, then pad for sorting
        temp_score = padded(player_stats[i].score + 100000000, -15, "0")
        temp_delta = comma_value(player_stats[i].last_delta)
        if player_stats[i].last_delta > 0 then
            temp_delta = "+" .. temp_delta
        end
        temp_leaderboard[i] = temp_score .. "|" .. player_stats[i].name .. " (" .. temp_delta .. ")"
    end
    table.sort(temp_leaderboard, function(a,b) return a>b end)
    for i=1, 10 do
    if temp_leaderboard[i] == nil then
        leaderboard[i].text = i .. ". (empty)"
    else
        -- convert score back to normal
        temp_score = comma_value(tonumber(string.sub ( temp_leaderboard[i], 1, string.find ( temp_leaderboard[i], "|" ) - 1 )) - 100000000)
        temp_name = string.sub( temp_leaderboard[i], string.find ( temp_leaderboard[i], "|" ) + 1 )
        leaderboard[i].text = i .. ". " .. temp_score .. " " .. temp_name
    end
    leaderboard[i]:setReferencePoint(display.CenterLeftReferencePoint)
    leaderboard[i].x = 40
    end
end

-- set up the interface
title = display.newText ( "PubNub, Ansca Corona SDK & BeyondtheTech present", 0, 0, "Helvetica-Bold", 12)
title:setTextColor (255,128,255)
title.x = 160
title.y = 35

point_value_text = display.newText ( "Connecting...", 0, 0, "Helvetica-Bold", 20)
point_value_text:setTextColor (255,255,0)
point_value_text.x = 160
point_value_text.y = 300

equation_text = display.newText ( "MATHEMANIA", 0, 0, "Helvetica-Bold",80)
equation_text:setTextColor (255,255,255)
equation_text.x = 160
equation_text.y = 160
reset_equation_graphics()

your_score_text = display.newText ( "Your Score: 0", 0, 0, "Helvetica-Bold", 24)
your_score_text:setTextColor (0,255,255)
your_score_text.x = 160
your_score_text.y = 460

game_clock_text = display.newText ( 0, 0, 0, "Helvetica-Bold", 12)
game_clock_text:setTextColor (64, 64, 64)
game_clock_text.x = 20
game_clock_text.y = 460

leaderboard_group = display.newGroup()
for i=1, 10 do
    leaderboard[i] = display.newText ( i .. ". " .. "(empty)", 0, 0, "Helvetica-Bold", 12)
    leaderboard[i].y = 60 + (i*18)
    leaderboard[i]:setReferencePoint(display.CenterLeftReferencePoint)
    leaderboard[i].x = 40
    leaderboard_group:insert(leaderboard[i])
end
leaderboard_group.alpha = 0.1

for i=1, 5 do
    button[i] = ui.newButton {
        defaultSrc = "button.png", defaultX = 64, defaultY = 64,
        overSrc = "button_lit.png", overX = 72, overY = 72,
        onEvent = button_handler,
        id = i
    }
    button[i].x = -32 + (64 * i)
    button[i].y = 380
    button_text[i] = display.newText ( "", 0, 0, "Helvetica-Bold", 20)
    button_text[i].x = button[i].x
    button_text[i].y = button[i].y    
end

-- start the loop
game_clock_loop()