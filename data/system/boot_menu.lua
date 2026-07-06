local Text = require("lib.text")
local Font4x6 = require("lib.fonts.4x6")

local text = Text.new(Font4x6)

local _MANIFEST = {}
local ENTRYPOINT_SCRIPT_NAME = "main.lua"

local CURSOR_COLOR = rgb(255, 255, 255)
local CURSOR_BLINK_HZ = 1.5
-- Cursor input move repeat
local REPEAT_DELAY = 0.25
local REPEAT_INTERVAL = 0.1

-- TILE×TILE pixels per slot; TILE_COLS * TILE_ROWS slots (row-major).
-- Values set in refresh_tile_geometry_from_manifest() from screen size and #_MANIFEST.
local TILE = 1
local TILE_COLS = SCREEN_W // TILE
local TILE_ROWS = SCREEN_H // TILE
local TEXT_HEIGHT = text.get_text_height()
local MENU_H = SCREEN_H - TEXT_HEIGHT



-- Cursor in tile coordinates (0 .. TILE_COLS-1, 0 .. TILE_ROWS-1)
local cursor_x = 0
local cursor_y = 0

-- Create the composite manifest table from a file system walk
-- Any top level directory containing a `manifest.lson` file is considered to be a game
-- `main.lua` will be used as the entrypoint for that game.
function collect_manifests()
  local manifest = {}

  local nodes = list_directory("/")

  for i_path, i_node_type in pairs(nodes) do
    if i_node_type == false then -- if directory
      -- Try to find a manifest.lua file in any first-level directory
      local nodes_in_dir = list_directory(i_path)

      for j_path, j_node_type in pairs(nodes_in_dir) do
        if string.find(j_path, "manifest.lua") then
          -- Convert the file path into a module name by removing the extension and replacing the
          -- path separator with a dot
          local module_name = string.gsub(j_path, ".lua$", "")
          module_name = module_name:sub(2) -- Remove the leading slash
          module_name = string.gsub(module_name, "/", ".")

          -- A manifest fragment MUST return a table with at least a "color" and "title" field
          -- Load the manifest through a Lua require.
          local metadata = require(module_name)

          local game = {
            -- Get the entrypoint path
            entrypoint = i_path .. "/" .. ENTRYPOINT_SCRIPT_NAME,
            metadata = metadata
          }

          table.insert(manifest, game)
        end
      end
    end
  end

  table.sort(manifest, function(a, b)
    return a.metadata.title < b.metadata.title
  end)

  return manifest
end

-- TILE must divide both W and H (no partial strip). Among those common divisors,
-- pick the largest such that the tile grid holds all manifest entries.
-- Basically, for this screen size, the values 1, 2, 5, 10 are all valid and make a nice
-- tiling without leftover spaces, and can accomodate respectively 200, 100, 16 and 4
-- games in the manifest. So we pick the largest one that can fit all games
function refresh_tile_geometry_from_manifest()
  local W, H = SCREEN_W, MENU_H
  local n = (_MANIFEST ~= nil) and #_MANIFEST or 0
  if n < 1 then
    TILE = 1
    TILE_COLS = W
    TILE_ROWS = H
    return
  end

  local best = 1
  for c = math.min(W, H), 1, -1 do
    if W % c == 0 and H % c == 0 then
      local cols = W // c
      local rows = H // c
      if cols * rows >= n then
        best = c
        break
      end
    end
  end

  TILE = best
  TILE_COLS = W // TILE
  TILE_ROWS = H // TILE
end

function tile_to_manifest_index(tx, ty)
  return ty * TILE_COLS + tx + 1
end

function build_menu_text()
  if _MANIFEST == nil or #_MANIFEST == 0 then
    text.reset()
    return
  end

  local selected_index = tile_to_manifest_index(cursor_x, cursor_y)
  local game = _MANIFEST[selected_index]
  local label = ""

  if game then
    label = game.metadata.title or "Untitled"
  end

  text.set_text(label .. "    ") -- FIXME: should be SCREEN_W / 5 spaces
end

function setup()
  _MANIFEST = collect_manifests()
  refresh_tile_geometry_from_manifest()
  build_menu_text()
  set_repeat_delay(REPEAT_DELAY)
  set_repeat_interval(REPEAT_INTERVAL)
end

function update(delta_time)
  text.scroll(delta_time)
end

function draw()
  clear()

  if _MANIFEST == nil then
    return
  end

  for ty = 0, TILE_ROWS - 1 do
    for tx = 0, TILE_COLS - 1 do
      local i = tile_to_manifest_index(tx, ty)
      local game = _MANIFEST[i]
      if game then
        -- Draw a tile representing the game in the menu
        local px = tx * TILE
        local py = ty * TILE
        rect(px, py, TILE, TILE, game.metadata.color)
      end
    end
  end

 draw_cursor()
 text.draw(0, SCREEN_H - TEXT_HEIGHT)
end

function draw_cursor()
  local cursor_blink_phase = math.floor(get_time() * 2 * CURSOR_BLINK_HZ) % 2
  local px = cursor_x * TILE
  local py = cursor_y * TILE

  if cursor_blink_phase == 0 then
    rect(px, py, TILE, TILE, CURSOR_COLOR)
  else
    rect_blend(px, py, TILE, TILE, CURSOR_COLOR, 0.1)
  end
end

function on_press(button)
  if button == "MENU" then
    local i = tile_to_manifest_index(cursor_x, cursor_y)
    local game = _MANIFEST[i]
    if game then
      -- Special privileged binding, only available in this boot menu context, to launch a game by its path.
      launch_game(game.entrypoint)
    end
  end

  move_cursor(button)
end

function on_repeat(button)
  move_cursor(button)
end

function move_cursor(button)
  -- Move the cursor
  if button == "R_LEFT" or button == "L_LEFT" then cursor_x = cursor_x - 1 end
  if button == "R_RIGHT" or button == "L_RIGHT" then cursor_x = cursor_x + 1 end
  if button == "R_UP" or button == "L_UP" then cursor_y = cursor_y - 1 end
  if button == "R_DOWN" or button == "L_DOWN" then cursor_y = cursor_y + 1 end

  cursor_x = cursor_x % TILE_COLS
  cursor_y = cursor_y % TILE_ROWS

    -- Refresh the ticker text to match the newly selected game
  build_menu_text()
end
