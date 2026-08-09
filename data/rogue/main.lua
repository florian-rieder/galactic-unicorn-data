-- Main
local Vector2 = require("lib.vector2")
local Enum = require("lib.enum")

-- Global player instance
player = require("rogue.player")
map = require("rogue.map") -- Make map a global

local VerticalProgressBar = require("rogue.verticalprogressbar")
local Enemy = require("rogue.enemy")

local viewport = require("rogue.viewport")
local xp_bar = VerticalProgressBar.new(
  0, 100,
  SCREEN_W - 2,
  rgb(255, 255, 0)
)
local health_bar = VerticalProgressBar.new(
  100, 100,
  SCREEN_W - 1,
  rgb(255, 0, 0)
)

local PLAYER_COLOR = rgb(255, 255, 2)
local WALL_COLOR = rgb(191, 191, 191)
local FLOOR_COLOR = rgb(49, 49, 49)
local CORRIDOR_COLOR = rgb(97, 97, 97)
local STAIRCASE_COLOR = rgb(86, 194, 224)
local VOID_COLOR = rgb(0, 0, 0)
local SPECIAL_COLOR = rgb(221, 0, 255)
local ENEMY_COLOR = rgb(178, 28, 28)

local GAME_OVER_COLOR = rgb(96, 26, 35)

local MAX_FLOOR_LEVEL = 8 -- How many floor levels to climb to win
local HEAL_PER_TURN = 1

local BASE_ENEMY_HEALTH = 20
local ENEMY_HEALTH_PER_FLOOR = 10
local BASE_ENEMY_DAMAGE = 5
local ENEMY_DAMAGE_PER_FLOOR = 5
local BASE_ENEMY_XP = 10
local ENEMY_XP_PER_FLOOR = 10

local GameState = Enum{"PLAYING", "WON", "LOST"}
local game_state = GameState.PLAYING
local enemies
local floor_level = 1

function setup()
  player.reset()
  floor_level = 1

  generate_floor()

  -- Register callbacks
  player.set_on_die(on_die)
  player.set_on_level_up(on_level_up)

  health_bar:set_max(player.get_max_health())
  health_bar:set_value(player.get_health())
  xp_bar:set_max(player.get_xp_requirement_to_next_level())
  xp_bar:set_value(player.get_xp_gained_to_next_level())

  game_state = GameState.PLAYING

  render()
end

function on_level_up()
  health_bar:set_max(player.get_max_health())
  xp_bar:set_max(player.get_xp_requirement_to_next_level())
  xp_bar:set_value(player.get_xp_gained_to_next_level())
end

function on_die()
  loose()
  render()
end

function render()
  if game_state == GameState.LOST then
    fill(GAME_OVER_COLOR)
    return
  end

  fill(VOID_COLOR)

  -- Draw map
  for x = 0, SCREEN_W do
    for y = 0, SCREEN_H do
      local screen_pos = Vector2.new(x, y)
      local world_pos = viewport.to_world(screen_pos)
      local tile = map.get_tile(world_pos.x, world_pos.y)

      if tile.discovered then
        if tile.type == TileType.WALL then
          set_pixel(x, y, WALL_COLOR)
        elseif tile.type == TileType.FLOOR then
          set_pixel(x, y, FLOOR_COLOR)
        elseif tile.type == TileType.CORRIDOR then
          set_pixel(x, y, CORRIDOR_COLOR)
        elseif tile.type == TileType.STAIRCASE then
          set_pixel(x, y, STAIRCASE_COLOR)
        elseif tile.type == TileType.SPECIAL then
          set_pixel(x, y, SPECIAL_COLOR)
        end
      end
    end
  end

  -- Draw enemies
  for _, enemy in ipairs(enemies) do
    local tile = map.get_tile(enemy.pos.x, enemy.pos.y)
    local screen_pos = viewport.to_screen(enemy.pos)

    if tile.discovered then
      local alpha = enemy.health / enemy.max_health
      alpha = 0.3 + alpha * 0.7
      alpha = math.min(1, math.max(0, alpha))
      set_pixel_blend(screen_pos.x, screen_pos.y, ENEMY_COLOR, alpha)
    end
  end

  -- Draw player
  screen_player_pos = viewport.to_screen(player.get_position())
  set_pixel(screen_player_pos.x, screen_player_pos.y, PLAYER_COLOR)

  -- Draw health bar
  health_bar:draw()
  xp_bar:draw()
end

function step(btn)
 if game_state == GameState.LOST or game_state == GameState.WON then
    -- Reset the game if any key is pressed while the game is over
    setup()
  end


  local direction
  if btn == "L_LEFT" then direction = Vector2.LEFT
  elseif btn == "L_RIGHT" then direction = Vector2.RIGHT
  elseif btn == "L_UP" then direction = Vector2.UP
  elseif btn == "L_DOWN" then direction = Vector2.DOWN
  elseif btn == "ESC" then take_stairs()
  else return end -- Skip all other input

  if direction then
    move(direction)
  end

  -- garbage collect dead enemies
  local alive = {}
  for _, e in ipairs(enemies) do
    if not e.dead then table.insert(alive, e) end
  end
  enemies = alive

  for _, e in ipairs(enemies) do
    e:decide()
    e:act()
  end

  -- Heal each turn
  player.heal(HEAL_PER_TURN)

  health_bar:set_value(player.get_health())

  render()
end

function on_press(btn)
  step(btn)
end

function on_repeat(btn)
  step(btn)
end

function move(direction)
  local new_player_pos = player.get_position() + direction

  if not map.can_move(new_player_pos) then return end

  for _, enemy in ipairs(enemies) do
    if enemy.pos == new_player_pos then
      -- If we bump into an enemy, don't move, but instead attack the enemy
      enemy:take_damage(player.get_damage())

      if enemy.dead then
        player.gain_xp(enemy:get_xp())
        xp_bar:set_value(player.get_xp_gained_to_next_level())
      end
      return
    end
  end

  player.set_position(new_player_pos)
  map.discover(new_player_pos.x, new_player_pos.y)

  local ps = viewport.to_screen(new_player_pos)
  -- Deadzone
  if ps.x < viewport.deadzone_margin.x or ps.x >= SCREEN_W - viewport.deadzone_margin.x or ps.y < viewport.deadzone_margin.y or ps.y >= SCREEN_H - viewport.deadzone_margin.y then
    viewport.pan(direction)
  end
end

function generate_floor()
  map.generate()

  -- Select starting room
  local start_room = map.get_random_room()
  local start_x = start_room.x + math.random(start_room.width - 1)
  local start_y = start_room.y + math.random(start_room.height - 1)

  enemies = {}
  for id, room in pairs(map.rooms) do
    if room.x ~= start_room.x or room.y ~= start_room.y then 
      local x = room.x + math.random(room.width - 2)
      local y = room.y + math.random(room.height - 2)
      local pos = Vector2.new(x, y)

      local enemy = Enemy.new(pos)

      local enemy_damage = BASE_ENEMY_DAMAGE + ENEMY_DAMAGE_PER_FLOOR * (floor_level - 1) + math.random(-2, 2)
      local enemy_health = BASE_ENEMY_HEALTH + ENEMY_HEALTH_PER_FLOOR * (floor_level - 1) + math.random(-5, 5)
      enemy.health = enemy_health
      enemy.damage = enemy_damage
      enemy.xp_loot = BASE_ENEMY_XP + ENEMY_XP_PER_FLOOR * (floor_level - 1)

      table.insert(enemies, enemy)
    end
  end

  player.set_position(Vector2.new(start_x, start_y))
  map.discover(start_x, start_y)

  viewport.pos.x = start_x - math.floor(SCREEN_W / 2)
  viewport.pos.y = start_y - math.floor(SCREEN_H / 2)
end

function take_stairs()
  local player_pos = player.get_position()
  local tile = map.get_tile(player_pos.x, player_pos.y)

  if tile.type ~= TileType.STAIRCASE then return end

  -- For now just reset the game
  -- TODO: Go to next level, make enemies stronger
  floor_level = floor_level + 1

  if floor_level >= MAX_FLOOR_LEVEL then
    win()
    return
  end

  -- TODO proper next level
  generate_floor()
end

function win()
  game_state = GameState.WIN
end

function loose()
  game_state = GameState.LOST
end

function can_move(destination_pos)
  if not map.can_move(destination_pos) then return false end

  for _, e in ipairs(enemies) do
    if e.pos == destination_pos then return false end
  end

  return true
end
