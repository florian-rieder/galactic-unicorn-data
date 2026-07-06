local video_player = require("video.player")

LEVELS = {
    {
    "  #           ##### ",
    "  ###     ##      T ",
    " ## # #####  #### ##",
    " #  # #      #  # # ",
    " ## ### T## ##  # # ",
    "E #       ###  ## # ",
    "  ##### ###   ##  # ",
    " T    #     T #   # ",
    " ############ ##### ",
    "      S             "
  },
  {
    "    #######   #     ",
    " #    # # ### # ##T ",
    " ###### #   ### #   ",
    "          ### # ### ",
    "  ### ##T     # # # ",
    "E## ### #######   # ",
    "                ### ",
    "#T     #### T####   ",
    " #     #  ##    ### ",
    " #####S#   ###    # "
  },
  {
    " ###### ######      ",
    " #    #  #   #  ##T ",
    "## ## ## # # ## # # ",
    " #  #  # # #  ### # ",
    " ## #  #T# #        ",
    "E ####     ##### ###",
    "       ##      ### #",
    "#T####  ####T ##   #",
    "    #       #     ##",
    "  ####S#### ####### "
  }
}

LEVEL_COLORS = {
  rgb(255, 0, 0),
  rgb(0, 255, 0),
  rgb(0, 0, 255),
}
PLAYER_COLOR = rgb(255, 255, 255)

-- Repeat-on-hold
local REPEAT_DELAY = 0.25
local REPEAT_INTERVAL = 0.1

local current_level_index = 1
local player_pos

function setup()
  player_pos = find_start_pos()
  set_repeat_delay(REPEAT_DELAY)
  set_repeat_interval(REPEAT_INTERVAL)
end

function update(dt)
  video_player.update(dt)
end

function draw()
  clear()
  read_level(function(x, y, char)
    if char == "#" or char == "S" then
      set_pixel(x, y, LEVEL_COLORS[current_level_index])
    elseif char == "T" then
      set_pixel(x, y, hsl(get_time()*100, 1, 0.5))
    elseif char == "E" then
      set_pixel(x, y, rgb(200, 200, 200))
    end
  end)

  set_pixel(player_pos.x, player_pos.y, PLAYER_COLOR)

  video_player.draw()
end

function on_press(btn)
  if btn == "L_BUMP" or btn == "R_BUMP" then
    if get_char_at_pos(player_pos.x, player_pos.y) == "T" then
      local increment
      if btn == "L_BUMP" then increment = -1
      elseif btn == "R_BUMP" then increment = 1 end

      current_level_index = (current_level_index - 1 + increment) % 3 + 1

      return
    end
  end

  if btn == "MENU" and video_player.playing then
    video_player.stop()
  end

  try_move(btn)
end

function on_repeat(btn)
  try_move(btn)
end

function try_move(btn)
  local new_dir
  if btn == "L_LEFT" or btn == "R_LEFT" then new_dir = {x=-1, y=0}
  elseif btn == "L_RIGHT" or btn == "R_RIGHT" then new_dir = {x=1, y=0}
  elseif btn == "L_UP" or btn == "R_UP" then new_dir = {x=0, y=-1}
  elseif btn == "L_DOWN" or btn == "R_DOWN" then new_dir = {x=0, y=1}
  else return end

  local new_pos_x = player_pos.x + new_dir.x
  local new_pos_y = player_pos.y + new_dir.y
  local char_at_new_pos = get_char_at_pos(new_pos_x, new_pos_y)

  if char_at_new_pos == " " then return end

  player_pos.x = new_pos_x
  player_pos.y = new_pos_y

  if char_at_new_pos == "E" then
    on_win()
  end
end

function on_video_end()
  -- reset the game
  player_pos = find_start_pos()
  current_level_index = 1
end

function on_win()
  print("WIN")
  -- Cinematics !
  video_player.play("/video/rickroll.guv", on_video_end)
end

function read_level(fn)
  for y = 0, SCREEN_H - 1, 1 do
    for x = 0, SCREEN_W - 1, 1 do
      local char = get_char_at_pos(x, y)
      fn(x, y, char)
    end
  end
end

function find_start_pos()
  local pos
  read_level(function(x, y, char)
    if char == "S" then
      pos = {x=x, y=y}
      return
    end
  end)
  return pos
end

function get_char_at_pos(x, y)
  if x < 0 or x >= SCREEN_W then return " " end
  if y < 0 or y >= SCREEN_H then return " " end
  local level = LEVELS[current_level_index]
  local char = string.sub(level[y + 1], x + 1, x + 1)
  return char
end
