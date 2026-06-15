-- Bresenham's line algorithm
-- Draw a line between two points
-- see https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

local function line(x0, y0, x1, y1, rgb_color)
  local dx = math.abs(x1 - x0)
  local dy = math.abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx - dy

  while true do
    set_pixel(x0, y0, rgb_color)

    -- We reached the end, close the loop
    if x0 == x1 and y0 == y1 then break end

    local e2 = 2 * err

    if e2 > -dy then
      err = err - dy
      x0 = x0 + sx
    end

    if e2 < dx then
      err = err + dx
      y0 = y0 + sy
    end
  end
end

if (...) == nil then
  line(0, 0, 19, 9, rgb(255, 0, 0))
  line(0, 9, 19, 0, rgb(0, 0, 255))
  line(0, 0, 2, 9, rgb(0, 255, 0))
  line(3, 9, 4, 0, rgb(255, 255, 0))
end

return line
