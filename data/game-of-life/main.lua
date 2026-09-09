DEAD_COLOR = rgb(0, 0, 0)
ALIVE_COLOR = rgb(248, 98, 241)
GENERATIONS_PER_SECOND = 12

OVERCROWDING_THRESHOLD = 3
UNDERPOPULATION_THRESHOLD = 2
BIRTH_THRESHOLD = 3

CELLS = {}

local last_update = 0

-- Translate a cell position into an index for the CELLS table
function idx(x, y)
  -- Loop around the edges
  if x < 0 then x = SCREEN_W - 1
  elseif x >= SCREEN_W then x = 0 end
  if y < 0 then y = SCREEN_H - 1
  elseif y >= SCREEN_H then y = 0 end

  return x + y * SCREEN_W
end

function get_alive_neighbors_count(x, y)
  local count = 0
  for dx = -1, 1 do
    for dy = -1, 1 do
      if dx == 0 and dy == 0 then goto continue end
      local px = x + dx
      local py = y + dy
      local is_alive = CELLS[idx(px, py)]

      if is_alive then
        count = count + 1
      end

      ::continue::
    end
  end

  return count
end

function setup()
  for x = 0, SCREEN_W -1 do
    for y = 0, SCREEN_H -1 do
      local is_alive = math.random(1, 100) < 30
      local index = idx(x, y)

      if is_alive then
        CELLS[index] = true
      end
    end
  end

  last_update = get_time()
end

function update(delta_time)
  local now = get_time()
  if now - last_update < 1 / GENERATIONS_PER_SECOND then return end

  local new_cells = {}
  for x = 0, SCREEN_W -1 do
    for y = 0, SCREEN_H -1 do
      local index = idx(x, y)
      local is_alive = CELLS[index]
      local neighbors = get_alive_neighbors_count(x, y)

      if is_alive then
        if neighbors >= UNDERPOPULATION_THRESHOLD and neighbors <= OVERCROWDING_THRESHOLD then
          new_cells[index] = true
        end
      else
        if neighbors == BIRTH_THRESHOLD then
          new_cells[index] = true
        end
      end
    end
  end

  CELLS = new_cells
  last_update = now
end

function draw()
  clear()
  for x = 0, SCREEN_W -1 do
    for y = 0, SCREEN_H -1 do
      local is_alive = CELLS[idx(x, y)]

      if is_alive then
        set_pixel(x, y, ALIVE_COLOR)
      else
        set_pixel(x, y, DEAD_COLOR)
      end
    end
  end
end
