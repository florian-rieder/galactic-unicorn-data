local Vector2 = require("lib.vector2")

local Projectile = {}
Projectile.mt = {}

-- Enables method calls on instances
Projectile.mt.__index = Projectile.mt

function Projectile.mt:move(dt)
  self.position = self.position + self.velocity * dt
  if self.position.x > SCREEN_W - 1 or self.position.x < 0 then
    self.dead = true
  end
end

function Projectile.mt:is_collision(pos)
  local floored_self_pos = Vector2.new(math.floor(self.position.x), math.floor(self.position.y))
  local floored_pos = Vector2.new(math.floor(pos.x), math.floor(pos.y))

  return floored_self_pos == floored_pos
end

function Projectile.new(pos, velocity)
  local proj = {
    position = pos:copy(),
    velocity = velocity:copy(),
    dead = false,
  }
  setmetatable(proj, Projectile.mt)
  return proj
end

return Projectile