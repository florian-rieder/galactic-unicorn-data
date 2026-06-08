local Enum = require("lib.enum")
local Vector2 = require("lib.vector2")
local Player = require("duel.player")

local MAX_CHARGE_TIME = 1 -- s
local PLAYER_MOVEMENT_SPEED = 5 -- px/s

local COLORS = {
  L = rgb(11, 80, 255),
  R = rgb(229, 103, 31),
}

local GameState = Enum{"LEFT_WIN", "RIGHT_WIN", "PLAYING"}

local projectiles
local held
local state
local players

function setup()
  players = {
    L = Player.new(1, Vector2.RIGHT, function() game_over("R") end),
    R = Player.new(SCREEN_W - 2, Vector2.LEFT, function() game_over("L") end),
  }
  projectiles = {
    L = {},
    R = {}
  }
  held = {}
  state = GameState.PLAYING
end

function game_over(winner_side)
  if state ~= GameState.PLAYING then return end

  -- Delete all projectiles
  projectiles.L = {}
  projectiles.R = {}

  print("Winner: " .. winner_side)
  if winner_side == "L" then
    state = GameState.LEFT_WIN
  elseif winner_side == "R" then
    state = GameState.RIGHT_WIN
  else error("Unknown side") end
end


function update(dt)
  if (is_pressed("L_UP")) then players.L.position = players.L.position + Vector2.UP * (PLAYER_MOVEMENT_SPEED * dt) end
  if (is_pressed("L_DOWN")) then players.L.position = players.L.position + Vector2.DOWN * (PLAYER_MOVEMENT_SPEED * dt) end
  if (is_pressed("R_UP")) then players.R.position = players.R.position + Vector2.UP * (PLAYER_MOVEMENT_SPEED * dt) end
  if (is_pressed("R_DOWN")) then players.R.position = players.R.position + Vector2.DOWN * (PLAYER_MOVEMENT_SPEED * dt) end

  if players.L.position.y > SCREEN_H - 1 then players.L.position.y = SCREEN_H - 1 end
  if players.L.position.y < 0 then players.L.position.y = 0 end
  if players.R.position.y > SCREEN_H - 1 then players.R.position.y = SCREEN_H - 1 end
  if players.R.position.y < 0 then players.R.position.y = 0 end

  for btn, start in pairs(held) do
    local t = get_time() - start
    if t >= MAX_CHARGE_TIME then
      if btn == "ESC" then
        proj = players.L:fire(t)
        table.insert(projectiles.L, proj)
      elseif btn == "MENU" then
        proj = players.R:fire(t)
        table.insert(projectiles.R, proj)
      end

      held[btn] = nil
    end
  end

  for side, proj_list in pairs(projectiles) do
    local alive = {}
    for _, proj in ipairs(proj_list) do
      if not proj.dead then
        proj:move(dt)

        local hit = false
        if side == "R" then
          if proj:is_collision(players.L.position) then
            players.L:take_hit()
            buzz(200, 50)
            hit = true
          end
        elseif side == "L" then
          if proj:is_collision(players.R.position) then
            players.R:take_hit()
            buzz(200, 50)
            hit = true
          end
        end

        if not hit then
          table.insert(alive, proj)
        end
      end
    end

    -- garbage collect dead projectiles
    projectiles[side] = alive
  end
end

function draw()
  clear()

  if state == GameState.RIGHT_WIN then
    fill(COLORS.R)
    return
  elseif state == GameState.LEFT_WIN then
    fill(COLORS.L)
    return
  end

  -- Draw projectiles
  for side, proj_list in pairs(projectiles) do
    for _, proj in ipairs(proj_list) do
      set_pixel_f(proj.position.x, proj.position.y, COLORS[side])
    end
  end

  -- Draw players
  set_pixel(math.floor(players.L.position.x), math.floor(players.L.position.y), COLORS.L)
  set_pixel(math.floor(players.R.position.x), math.floor(players.R.position.y), COLORS.R)

  -- Draw health bars

  rect(0, 0, 1, players.L.health, COLORS.L)
  rect(SCREEN_W - 1, 0, 1, players.R.health, COLORS.R)

end

function on_press(btn)
  if state ~= GameState.PLAYING then
    setup()
    return
  end
  if not held[btn] then
    held[btn] = get_time()
  end
end

function on_release(btn)
  if held[btn] then
    local t = get_time() - held[btn]
    local boost = t

    held[btn] = nil

    local proj
    if btn == "ESC" then
      proj = players.L:fire(boost)
      table.insert(projectiles.L, proj)
    elseif btn == "MENU" then
      proj = players.R:fire(boost)
      table.insert(projectiles.R, proj)
    end
  end
end
