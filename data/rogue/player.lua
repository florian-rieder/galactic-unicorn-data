local Vector2 = require("lib.vector2")

local BASE_MAX_HEALTH = 100
local HEALTH_PER_LEVEL = 15
local BASE_STRENGTH = 10
local STRENGTH_PER_LEVEL = 2
local XP_BASE = 50
local XP_EXPONENT = 1.8

local LEVEL_UP_HEAL_PERCENTAGE = 0.1

local function xp_required_for_level(lvl)
  if lvl < 0 then return 0 end
  return math.floor(XP_BASE * (lvl ^ XP_EXPONENT))
end

local Player = {}
Player.mt = {}

local position = Vector2.ZERO
local max_health = BASE_MAX_HEALTH
local health = BASE_MAX_HEALTH
local strength = BASE_STRENGTH
local level = 1
local xp = 0
local next_level_xp_requirement = xp_required_for_level(level)

-- Callbacks
local on_die = nil
local on_level_up = nil

local function level_up()
  level = level + 1
  next_level_xp_requirement = xp_required_for_level(level)
  max_health = BASE_MAX_HEALTH + HEALTH_PER_LEVEL * (level - 1)
  strength = BASE_STRENGTH + STRENGTH_PER_LEVEL * (level - 1)

  -- Heal (so the health bar doesn't look like you just took a big hit)
  Player.heal(0.25)

  if on_level_up ~= nil then on_level_up() end

  print("LEVEL:" .. tostring(level), "MAX_HEALTH:" .. tostring(max_health), "XP_REQ:" .. tostring(next_level_xp_requirement), "STRENGTH:" .. tostring(strength))
end

function Player.reset()
  position = Vector2.ZERO
  level = 1
  next_level_xp_requirement = xp_required_for_level(level)
  xp = 0
  max_health = BASE_MAX_HEALTH
  health = BASE_MAX_HEALTH
  strength = BASE_STRENGTH
end

function Player.get_position()
  return position:copy()
end

function Player.set_position(new_position)
  if not Vector2.is_instance(new_position) then
    error("new_position must be a Vector2", 2)
  end

  position = new_position
end

function Player.get_health()
  return health
end

function Player.get_max_health()
  return max_health
end

function Player.get_xp_requirement_to_next_level()
  return next_level_xp_requirement - xp
end

function Player.get_xp_gained_to_next_level()
  return xp - xp_required_for_level(level - 1)
end

function Player.take_damage(damage)
  health = health - math.abs(damage)

  if health <= 0 then
    if on_die ~= nil then on_die() end
  end
end

function Player.gain_xp(amount)
  xp = xp + math.abs(amount)

  print("Gained " .. tostring(amount) .. " XP; Current XP: " .. tostring(xp))

  if xp >= next_level_xp_requirement then
    level_up()
  end
end

function Player.get_damage()
  return strength
end

function Player.heal(amount)
  health = math.min(health + math.abs(amount), max_health)
end

function Player.set_on_die(fn)
  on_die = fn
end

function Player.set_on_level_up(fn)
  on_level_up = fn
end



if ... == nil then
  print("LEVEL:" .. tostring(level), "MAX_HEALTH:" .. tostring(max_health), "XP_REQ:" .. tostring(next_level_xp_requirement), "STRENGTH:" .. tostring(strength))

  for i = 1, 99 do
    level_up()
  end

end

return Player
