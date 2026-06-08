local Vector2 = require("lib.vector2")
local Projectile = require("duel.projectile")


local Player = {}
Player.mt = {}

-- Enables method calls on instances
Player.mt.__index = Player.mt


local FIRE_COOLDOWN = 0.5
local BOOST_MULT = 10
local PROJECTILE_SPEED = 5 -- px/s
local MAX_HEALTH = SCREEN_H


function Player.mt:take_hit()
  self.health = self.health - 1

  if self.health <= 0 then
    if self.on_die then self.on_die() end
  end
end

function Player.new(x, facing, on_die)
  local player = {
    position = Vector2.new(x, math.floor(SCREEN_H / 2)),
    health = MAX_HEALTH,
    on_die = on_die,
    facing = facing,
    last_fired = 0
  }

  setmetatable(player, Player.mt)

  return player
end

function Player.mt:fire(boost)
  if get_time() - self.last_fired < FIRE_COOLDOWN then return end
  self.last_fired = get_time()

  local pos = self.position:floor()
  local vel = self.facing * PROJECTILE_SPEED * (1 + boost * BOOST_MULT)

  local proj = Projectile.new(pos, vel)
  return proj
end

return Player
