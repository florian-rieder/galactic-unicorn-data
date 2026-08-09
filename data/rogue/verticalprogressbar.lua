local M = {}

M.mt = {}
M.mt.__index = M.mt

function M.new(value, max, x, color)
  local bar = {
    value = value,
    max = max,
    x = x,
    color = color
  }

  setmetatable(bar, M.mt)

  return bar

end

function M.mt:draw()
  local percentage = self.value / self.max
  local cell_value = self.max / SCREEN_H

  local full_cells = math.floor(self.value / cell_value)
  local remainder = (self.value - full_cells * cell_value) / cell_value

  for i = 0, SCREEN_H - 1 do
    if i < full_cells then
      set_pixel(self.x, SCREEN_H - i - 1, self.color)
    elseif i == full_cells then
      set_pixel_blend(self.x, SCREEN_H - i - 1, self.color, remainder)
    end
  end
end

function M.mt:set_value(value)
  if value > self.max then
    error("value over max " .. value .. " (max " .. self.max .. ")")
  end

  self.value = value
end

function M.mt:set_max(max)
  self.max = max

  if self.max < self.value then
    self.value = self.max
  end
end

function M.mt:set_color(color)
  -- TODO: validate it's an rgb table
  self.color = color
end


if (...) == nil then
  local xp_bar = M.new(
    5, 100,
    SCREEN_W - 2,
    rgb(255, 255, 0)
  )

  local health_bar = M.new(
    100, 100,
    SCREEN_W - 1,
    rgb(255, 0, 0)
  )

  function setup()
    clear()
    xp_bar:draw()
    health_bar:draw()
  end

  function on_press(btn) 
    if btn == "R_UP" then xp_bar.value = xp_bar.value + 1
    elseif btn == "R_DOWN" then xp_bar.value = xp_bar.value - 1 end
    
    if xp_bar.value < 0 then xp_bar.value = 0
    elseif xp_bar.value > xp_bar.max then xp_bar.value = xp_bar.max end

    clear()
    xp_bar:draw()
    health_bar:draw()
  end
end

return M
