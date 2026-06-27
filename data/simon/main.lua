-- following the original, physical game which uses notes from an A major triad in second inversion
-- blue (lower left): E
-- yellow (lower left): C#
-- red (upper right): A
-- green (upper left): E, one octave above blue
-- to account for console design, rotate clockwise
-- consider C4 as base
-- current gameplay: p1 sets pattern, p2 copies, if p1 forgets pattern p2 wins, if p2 forgets pattern p1 wins
-- or randomized pattern and both players recreate

colors = {"g", "r", "b", "y"}
sequence = {}
turn = 1

-- states: "P1_PLAYBACK", "P1_ADD", "P2_COPY", "GAME_OVER"
game_state = "P1_PLAYBACK" 

flash_active_timer = 0
active_flash_color = nil
light_duration = 0.4

alert_timer = 0
alert_type = nil

winner = nil

function get_note_freq(color)
    if color == "g" then return 659 end
    if color == "r" then return 440 end
    if color == "b" then return 330 end
    if color == "y" then return 277 end
    return 0
end
-- i replaced the original color functions with this
function get_button_color(button_name, expected_player)
    if expected_player == 1 then
        if button_name == "L_UP"    then return "g" end
        if button_name == "L_RIGHT" then return "r" end
        if button_name == "L_DOWN"  then return "b" end
        if button_name == "L_LEFT"  then return "y" end
    elseif expected_player == 2 then
        if button_name == "R_UP"    then return "g" end
        if button_name == "R_RIGHT" then return "r" end
        if button_name == "R_DOWN"  then return "b" end
        if button_name == "R_LEFT"  then return "y" end
    end
    return nil
end

function trigger_flash(color)
    active_flash_color = color
    flash_active_timer = light_duration
    buzz(get_note_freq(color), light_duration * 1000)
end

function trigger_alert(type)
    alert_type = type
    alert_timer = 1.0
    if type == "GAME_OVER" then
        buzz(150, 600)
    end
end

function setup()
    sequence = {}
    game_state = "P1_PLAYBACK"
    turn = 1
    alert_timer = 0
    alert_type = nil
    active_flash_color = nil
    flash_active_timer = 0
    
    clear()
    draw()
end


function update(delta_time)
    if alert_timer and alert_timer > 0 then
        alert_timer = alert_timer - delta_time
    end

    if flash_active_timer and flash_active_timer > 0 then
        flash_active_timer = flash_active_timer - delta_time
        if flash_active_timer <= 0 then
            active_flash_color = nil
        end
    end
end

-- puts buttons on screen
function draw()
    clear()

    if alert_timer and alert_timer > 0 then
        if alert_type == "GAME_OVER" then
            if winner == 1 then
              rect_f(10, 0, 10, 10, rgb(255, 0, 0))
            elseif winner == 2 then
              rect_f(0, 0, 10, 10, rgb(255, 0, 0))
            end
        end
        return
    end

    local g_color = (active_flash_color == "g") and rgb(0, 255, 0) or rgb(0, 50, 0)
    local r_color = (active_flash_color == "r") and rgb(255, 0, 0) or rgb(50, 0, 0)
    local b_color = (active_flash_color == "b") and rgb(0, 0, 255) or rgb(0, 0, 50)
    local y_color = (active_flash_color == "y") and rgb(255, 255, 0) or rgb(50, 50, 0)

    rect_f(9, 2, 2, 2, g_color)   
    rect_f(11, 4, 2, 2, r_color)  
    rect_f(9, 6, 2, 2, b_color)   
    rect_f(7, 4, 2, 2, y_color)   

    if game_state == "P1_PLAYBACK" then
      rect_f(0, 0, 1, 10, rgb(255, 255, 255))
    elseif game_state == "P1_ADD" then
      rect_f(0, 0, 1, 10, rgb(255, 255, 255))
    elseif game_state == "P2_COPY" then
      rect_f(19, 0, 1, 10, rgb(255, 255, 255))
    end
end

function on_press(button_name)
    if game_state == "GAME_OVER" then
        setup()
        return
    end

    -- p1 copies
    if game_state == "P1_PLAYBACK" then
        if #sequence == 0 then
            game_state = "P1_ADD"
        else
            local color = get_button_color(button_name, 1)
            if color then
                trigger_flash(color)
                if color == sequence[turn] then
                    turn = turn + 1
                    if turn > #sequence then
                        game_state = "P1_ADD"  
                    end
                    return 
                else
                    winner = 2
                    game_state = "GAME_OVER"
                    trigger_alert("GAME_OVER")
                    return
                end
            end
        end
    end

    -- p1 appends color/note
    if game_state == "P1_ADD" then
        local color = get_button_color(button_name, 1)
        if color then            
            table.insert(sequence, color)
            trigger_flash(color)
            game_state = "P2_COPY"
            turn = 1
            return
        end

    -- p2 copies sequence
    elseif game_state == "P2_COPY" then
        local color = get_button_color(button_name, 2)
        if color then
            trigger_flash(color)
            if color == sequence[turn] then
                turn = turn + 1
                if turn > #sequence then
                    game_state = "P1_PLAYBACK"
                    turn = 1
                end
                return
            else
                winner = 1
                game_state = "GAME_OVER"
                trigger_alert("GAME_OVER")
                return
            end
        end
    end
end
