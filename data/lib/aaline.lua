-- Xiaolin Wu's line algorithm
-- Draw an antialiased line between two points
-- see https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm
--     https://dl.acm.org/doi/epdf/10.1145/122718.122734

-- Fractional part of x
local function fpart(x)
  return x - math.floor(x)
end

local function rfpart(x)
  return 1 - fpart(x)
end

local function aa_line(x0, y0, x1, y1, rgb_color, thickness0, thickness1)
  if not thickness0 then thickness0 = 1 end
  thickness0 = math.max(0, math.min(thickness0, 1))
  if not thickness1 then thickness1 = 1 end
  thickness1 = math.max(0, math.min(thickness1, 1))
  local steep = math.abs(y1 - y0) > math.abs(x1 - x0)

  -- Steep: swap x and y to draw by row instead of by column
  if steep then
    x0, y0 = y0, x0
    x1, y1 = y1, x1
  end

  -- Make sure points are correctly ordered
  if x0 > x1 then
    x0, x1 = x1, x0
    y0, y1 = y1, y0
  end

  local slope = (y1 - y0) / (x1 - x0)

  -- Handle first endpoint
  local xend = math.floor(x0)
  local yend = y0 + slope * (xend - x0)
  local xgap = 1 - (x0 - xend)
  local xpxl1 = xend -- this will be used in the main loop
  local ypxl1 = math.floor(yend)

  -- Draw the first endpoint
  if steep then
      set_pixel_blend(ypxl1, xpxl1, rgb_color, rfpart(yend) * xgap * thickness0)
      set_pixel_blend(ypxl1+1, xpxl1, rgb_color, fpart(yend) * xgap * thickness0)
  else
      set_pixel_blend(xpxl1, ypxl1, rgb_color, rfpart(yend) * xgap * thickness0)
      set_pixel_blend(xpxl1, ypxl1+1, rgb_color, fpart(yend) * xgap * thickness0)
  end

  local intery = yend + slope -- first y-intersection for the main loop

  -- Handle second endpoint
  xend = math.ceil(x1)
  yend = y1 + slope * (xend - x1)
  xgap = 1 - (xend - x1)
  local xpxl2 = xend -- this will be used in the main loop
  local ypxl2 = math.floor(yend)

  -- Draw the second endpoint
  if steep then
      set_pixel_blend(ypxl2, xpxl2, rgb_color, rfpart(yend) * xgap * thickness1)
      set_pixel_blend(ypxl2+1, xpxl2, rgb_color, fpart(yend) * xgap * thickness1)
  else
      set_pixel_blend(xpxl2, ypxl2, rgb_color, rfpart(yend) * xgap * thickness1)
      set_pixel_blend(xpxl2, ypxl2+1, rgb_color, fpart(yend) * xgap * thickness1)
  end

  -- Main loop
  local lower, upper, thickness
  for i = xpxl1 + 1, xpxl2 - 1 do
    lower = math.floor(intery)
    upper = lower + 1

    -- Lerp thickness
    thickness = thickness0 + ((i - xpxl1) / (xpxl2 - xpxl1)) * (thickness1 - thickness0)

    if steep then
      set_pixel_blend(lower, i, rgb_color, rfpart(intery) * thickness)
      set_pixel_blend(upper, i, rgb_color, fpart(intery) * thickness)
    else
      set_pixel_blend(i, lower, rgb_color, rfpart(intery) * thickness)
      set_pixel_blend(i, upper, rgb_color, fpart(intery) * thickness)
    end
    intery = intery + slope
  end
end

if (...) == nil then
  -- Just a regular line
  aa_line(0, 0, 12, 4, rgb(255, 0, 0))
  -- Second point larger than first
  aa_line(12, 4, 19, 0, rgb(0, 0, 255))
  -- Steep slope
  aa_line(0, 0, 2, 9, rgb(0, 255, 0))
  -- Steep slope with second point larger than first
  aa_line(2, 9, 3, 0, rgb(255, 255, 0))
  -- With float coordinates
  aa_line(0.5, 4.1, 17.3, 8.6, rgb(255, 255, 255), 0.5, 0.1)
end

return aa_line
