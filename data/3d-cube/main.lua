-- 3D Rotating Cube
-- It's a 3D cube !

local line = require("lib.aaline")
local Vector3 = require("lib.vector3")

local CUBE_COLOR_PERSPECTIVE = rgb(0, 255, 0)
local CUBE_COLOR_ORTHO = rgb(97, 142, 255)
local CAMERA_DISTANCE = 2
local CAMERA_SCALE = SCREEN_H / 2
local ROTATION_SPEED = 0.75
local ROTATION_FACTOR = Vector3.new(1, 0.7, 0)
local SCREEN_CENTER = {
  x = SCREEN_W / 2,
  y = SCREEN_H / 2
}

local t = math.pi
local projection_perspective = true
local cube_color = CUBE_COLOR_PERSPECTIVE

local vertices = {
  Vector3.new(1, 1, 1),
  Vector3.new(1, -1, 1),
  Vector3.new(-1, 1, 1),
  Vector3.new(1, 1, -1),
  Vector3.new(-1, -1, 1),
  Vector3.new(1, -1, -1),
  Vector3.new(-1, 1, -1),
  Vector3.new(-1, -1, -1),
}
local edges = {}
local projected_vertices = {}


-- Projection

local function project_ortho(vec)
  return Vector3.new(
    ((vec.x + 1)/2) * (SCREEN_H - 1) + SCREEN_W / 4,
    ((vec.y + 1)/2) * (SCREEN_H - 1),
    1
  )
end

local function project_perspective(vec)
  local depth = vec.z + CAMERA_DISTANCE
  local px = vec.x / depth
  local py = vec.y / depth

  return Vector3.new(
    px * CAMERA_SCALE + SCREEN_CENTER.x,
    py * CAMERA_SCALE + SCREEN_CENTER.y,
    depth
  )
end

function setup()
  -- Generate edges of the cube
  local diff = Vector3.ZERO
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
        diff.x = v.x ~= w.x and 1 or 0
        diff.y = v.y ~= w.y and 1 or 0
        diff.z = v.z ~= w.z and 1 or 0

        -- if only one coordinate is different, then we have an edge of the cube
        if (diff.x + diff.y + diff.z == 1) then
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

  local angles = ROTATION_FACTOR * t

  -- Transform every vertex in the cube
  for i, vertex in ipairs(vertices) do
    -- Apply rotation to the vertex
    vertex = Vector3.rotate(vertex, Vector3.LEFT, angles.x)
    vertex = Vector3.rotate(vertex, Vector3.UP, angles.y)
    vertex = Vector3.rotate(vertex, Vector3.FORWARD, angles.z)

    -- Project the vertices to the screen
    if projection_perspective then
      vertex = project_perspective(vertex)
    else
      vertex = project_ortho(vertex)
    end

    projected_vertices[i] = vertex
  end

  -- Draw every edge in the cube
  local a,b
  for _, edge in ipairs(edges) do
    a = projected_vertices[edge[1]]
    b = projected_vertices[edge[2]]

    -- Draw the edge
    line(a.x, a.y, b.x, b.y, cube_color, 1 / a.z, 1 / b.z)
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
