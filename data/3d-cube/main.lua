-- 3D Rotating Cube
-- It's a 3D cube !

local line = require("lib.aaline")

local CUBE_COLOR_PERSPECTIVE = rgb(69, 215, 84)
local CUBE_COLOR_ORTHO = rgb(97, 142, 255)
local CAMERA_DISTANCE = 2
local CAMERA_SCALE = SCREEN_H / 2
local ROTATION_SPEED = 0.75
local ROTATION_FACTOR = {
  x = 1,
  y = 0.7,
  z = 0
}
local SCREEN_CENTER = {
  x = SCREEN_W / 2,
  y = SCREEN_H / 2
}

local t = 0
local projection_perspective = true
local cube_color = CUBE_COLOR_PERSPECTIVE

local vertices = {
  {1, 1, 1},
  {1, -1, 1},
  {-1, 1, 1},
  {1, 1, -1},
  {-1, -1, 1},
  {1, -1, -1},
  {-1, 1, -1},
  {-1, -1, -1},
}
local edges = {}

-- Projection

local function project_ortho(x, y, z)
  return {
    x = ((x + 1)/2) * (SCREEN_H - 1) + SCREEN_W / 4,
    y = ((y + 1)/2) * (SCREEN_H - 1)
  }
end

local function project_perspective(x, y, z)
  local px = x / (z + CAMERA_DISTANCE)
  local py = y / (z + CAMERA_DISTANCE)

  return {
    x = px * CAMERA_SCALE + SCREEN_CENTER.x,
    y = py * CAMERA_SCALE + SCREEN_CENTER.y
  }
end

-- Rotation

function rotate_x(x, y, z, angle)
  return {
    x,
    y * math.cos(angle) - z * math.sin(angle),
    y * math.sin(angle) + z * math.cos(angle)
  }
end

function rotate_y(x, y, z, angle)
  return {
    x * math.cos(angle) - z * math.sin(angle),
    y,
    x * math.sin(angle) + z * math.cos(angle)
  }
end

function rotate_z(x, y, z, angle)
  return {
    x * math.cos(angle) - y * math.sin(angle),
    x * math.sin(angle) + y * math.cos(angle),
    z
  }
end

function setup()
  -- Find all edges
  local checked_combinations = {}
  for i,v in ipairs(vertices) do
    for j,w in ipairs(vertices) do
      local a = math.min(i, j)
      local b = math.max(i, j)
      local key = a .. "_" .. b

      -- Check each combination exactly once
      if not checked_combinations[key] then
        checked_combinations[key] = true

        -- Find coordinate differences
        diff_x = v[1] ~= w[1] and 1 or 0
        diff_y = v[2] ~= w[2] and 1 or 0
        diff_z = v[3] ~= w[3] and 1 or 0

        -- if only one coordinate is different, then we have an edge of the cube
        if (diff_x + diff_y + diff_z == 1) then
          table.insert(edges, {a, b})
        end
      end
    end
  end
end

function update(delta_time)
  t = t + ROTATION_SPEED * delta_time
end

function draw()
  clear()

  local edge_a, edge_b, screen_a, screen_b

  -- Iterate over every edge in the cube
  for _, edge in ipairs(edges) do
    edge_a = vertices[edge[1]]
    edge_b = vertices[edge[2]]

    -- Apply rotation
    edge_a = rotate_x(edge_a[1], edge_a[2], edge_a[3], t * ROTATION_FACTOR.x)
    edge_b = rotate_x(edge_b[1], edge_b[2], edge_b[3], t * ROTATION_FACTOR.x)
    edge_a = rotate_y(edge_a[1], edge_a[2], edge_a[3], t * ROTATION_FACTOR.y)
    edge_b = rotate_y(edge_b[1], edge_b[2], edge_b[3], t * ROTATION_FACTOR.y)
    edge_a = rotate_z(edge_a[1], edge_a[2], edge_a[3], t * ROTATION_FACTOR.z)
    edge_b = rotate_z(edge_b[1], edge_b[2], edge_b[3], t * ROTATION_FACTOR.z)

    -- Project the edge's coordinates onto the screen
    if projection_perspective then
      screen_a = project_perspective(edge_a[1], edge_a[2], edge_a[3])
      screen_b = project_perspective(edge_b[1], edge_b[2], edge_b[3])
    else
      screen_a = project_ortho(edge_a[1], edge_a[2], edge_a[3])
      screen_b = project_ortho(edge_b[1], edge_b[2], edge_b[3])
    end
  
    -- Draw the edge
    line(screen_a.x, screen_a.y, screen_b.x, screen_b.y, cube_color)
  end
end

function on_press(btn)
  projection_perspective = not projection_perspective
  if projection_perspective then
    cube_color = CUBE_COLOR_PERSPECTIVE
  else
    cube_color = CUBE_COLOR_ORTHO
  end
end
