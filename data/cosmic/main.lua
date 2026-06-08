-- Cosmic
-- Two color gradient channels inter-mixing with random bright and colorful flashes
-- Author : Loïc Cattani (@loiccattani) june 2026

-- About performance optimisations in this code
-- To prevent the Lua garbage collector working too hard, all variables are pre-declared and reused instead of creating new one on each frames and loop iteration.
-- To ease the CPU load, we also precompute the flashing indexes and the sin values for the time component once per frame, instead of calling math.random and math.sin for every pixel on each frame.

-- Configuration
local enable_flashes = true
local flash_chance = 4 -- percent chance of flashing
local ch_a_cycle_time = 19 -- seconds for a full hue cycle in channel A
local ch_mix_transition_time = 13 -- seconds for a full transition between channel A and channel B
local default_sat = 1 -- 0 to 1, where 0 is gray and 1 is fully saturated color
local default_lum = 0.5 -- 0 to 1, where 0 is black and 1 is white

-- Internal state
local now -- current time in seconds at start of every frame
local pixel_index -- pixel index
local ch_a_cycle -- 0 to 2 interval for channel A hue (0 to 1 to increase hue angle, then 1 to 2 to decrease it)
local ch_a_hue -- hue angle for channel A
local ch_a_brightness -- brightness for channel A (hardware LED brightness)
local ch_b_lum -- luminosity for channel B
local ch_b_brightness -- brightness for channel B (hardware LED brightness)
local ch_mix_direction -- channel mixing direction (1 for A to B, -1 for B to A)
local ch_mix_step -- mix factor step per frame, calculated from ch_mix_transition_time
local ch_mix -- float 0 to 1 mix factor between channel A and channel B
local hue, sat, lum -- final hue, saturation and luminosity for the current pixel

-- Optimized flash randomness
local ch_a_flashing_indexes = {}
local ch_b_flashing_indexes = {}

-- Optimized sin math for channel B
-- Instead of calling math.sin for every pixel on each frame, we can separate the time and index components and precompute the sin values for the time component once per frame. Then we can just add the index component to it for each pixel.
local time_sin, time_cos
-- Precompute the sin and cos increments for ch_b_lum calculation
local lum_step = 0.15 -- This value controls the spatial frequency of the pattern. Higher values will create more waves across the screen.
local sin_offset = {}
local cos_offset = {}
for _i = 0, SCREEN_W * SCREEN_H - 1 do
  local angle = _i * lum_step
  sin_offset[_i] = math.sin(angle)
  cos_offset[_i] = math.cos(angle)
end

-- Setting defaults
sat = default_sat
ch_mix_direction = 1
ch_mix = 0

function draw()
  now = get_time()

  -- Calculate the mix factor for transitioning between channel A and channel B
  ch_mix_step = 1 / (ch_mix_transition_time * 60) * ch_mix_direction -- Assuming 60 FPS FIXME: get_fps()?
  if ch_mix < 1 then
    ch_mix = ch_mix + ch_mix_step
  end

  -- Auto-reverse
  if (ch_mix >= 0.999) then
    ch_mix_direction = -1
  elseif (ch_mix <= 0.1) then
    ch_mix_direction = 1
  end

  ch_mix = math.max(0, math.min(1, ch_mix))

  -- Optimized flashes
  -- Instead of using random on every pixel for both channel, we can precompute up to 8 flash indexes per channel per frame and check if the current pixel index matches any of them. This way we only call math.random 16 times per frame instead of 400 times.
  if enable_flashes then
    -- Clear previous flash indexes
    ch_a_flashing_indexes = {}
    ch_b_flashing_indexes = {}
    for _ = 1, flash_chance * SCREEN_W * SCREEN_H / 100 do
      ch_a_flashing_indexes[math.random(0, SCREEN_W * SCREEN_H - 1)] = true
      ch_b_flashing_indexes[math.random(0, SCREEN_W * SCREEN_H - 1)] = true
    end
  end

  -- Optimized sin math
  -- Precompute the sin values for the time component once per frame.
  time_sin = math.sin(now * 2)
  time_cos = math.cos(now * 2)

  for x = 0, SCREEN_W - 1 do
    for y = 0, SCREEN_H - 1 do
      pixel_index = x + y * SCREEN_W

      -- Compute channel A
      if enable_flashes and ch_a_flashing_indexes[pixel_index] ~= nil then
        ch_a_hue = 300
        ch_a_brightness = 9 -- Flash brightness (DO NOT GO ABOVE 9)
      else
        ch_a_cycle = ((now / ch_a_cycle_time * 1000 + pixel_index) % 1000) / 1000.0 * 2
        if (ch_a_cycle < 1) then
          ch_a_hue = 240 + ch_a_cycle * 120
        else
          ch_a_hue = 360 - (ch_a_cycle - 1) * 120
        end
        ch_a_brightness = 1
      end

      -- Compute channel B
      if enable_flashes and ch_b_flashing_indexes[pixel_index] ~= nil then
        ch_b_lum = default_lum
        ch_b_brightness = 9 -- Flash brightness (DO NOT GO ABOVE 9)
      else
        ch_b_lum = math.max(0, math.min(default_lum, (time_sin * sin_offset[pixel_index] + time_cos * cos_offset[pixel_index]) / 4))
        ch_b_brightness = 1
      end

      -- Mix channels and set pixel
      hue = math.floor(ch_a_hue + (120 - ch_a_hue) * ch_mix)

      lum = default_lum + (ch_b_lum - default_lum) * ch_mix

      -- Set the pixel color and brightness
      set_pixel(x, y, hsl(hue, sat, lum))
      set_unsafe_pixel_brightness(x, y, math.floor(ch_a_brightness + (ch_b_brightness - ch_a_brightness) * ch_mix))
    end
  end
end

function on_press(button)
  -- Toggle flashing
  if button == "MENU" then
    enable_flashes = not enable_flashes
  end
end
