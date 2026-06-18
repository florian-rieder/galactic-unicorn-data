local function clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

local function clamp01(value)
  return clamp(value, 0, 1)
end

local function lerp(from, to, time)
    return from + time * (to - from)
end

return { 
  clamp = clamp,
  clamp01 = clamp01,
  lerp = lerp
}
