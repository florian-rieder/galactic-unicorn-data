Vector3 = require("lib.vector3")

RADIUS = 6
CENTER = Vector3.new(SCREEN_W / 2 - 1 / 2, SCREEN_H / 2 - 1 / 2, 5)
CAMERA_DISTANCE = 0
ROTATION_SPEED = 0.5
TINT = rgb(46, 128, 241)

light_direction = Vector3.new(1, 0, 0)

function update(dt)
  light_direction = Vector3.rotate(light_direction, Vector3.DOWN, dt * ROTATION_SPEED)
end

function draw()
  for x = 0, SCREEN_W - 1 do
    for y = 0, SCREEN_H - 1 do
      local ray_origin = Vector3.new(x, y, CAMERA_DISTANCE)
      local ray_direction = Vector3.FORWARD

      local color = cast_ray_intercept_sphere(ray_origin, ray_direction)
      set_pixel(x, y, color)
    end
  end
end

function cast_ray_intercept_sphere(origin, direction)
  -- For a sphere of center C and radius r, a point X is part of the sphere if:
  -- Equation for a sphere: (X - C):length()^2 == r^2
  -- (The set of all points that are a distance r from the center)
  -- By definition, V:length()^2 == V . V, so (X - C) . (X - C) == r^2

  -- Now, our ray is an origin O and a direction D
  -- P(x) = O + D * x

  -- To find the intersection(s) between a ray and the sphere, substitute X with P(x)
  -- So the equation for the ray hit is:
  -- (P(x) - C) . (P(x) - C) == r^2
  -- => (O + D*x - C) . (O + D*x - C) == r^2
  -- => V = O - C => (V + D*x) . (V + D*x) == r^2
  -- => V.V + 2* (D*x . V) + D*x . D*x == r^2
  -- => V.V + 2x * (D.V) + x^2(D . D) == r^2
  -- => V . V + 2x * (D.V) + x^2(D . D) - r^2 == 0
  -- => (x^2) * (D . D) + 2x * (D . V) + (V . V) - r^2 == 0

  -- We can apply the quadratic formula to find x:
  -- x = (-b +- sqrt(b^2 - 4ac)) / 2a
  -- with:
  -- a = D.D
  -- b = 2 * (D.V)
  -- c = V.V - r^2

  local V = origin - CENTER
  local a = Vector3.dot(direction, direction)
  local b = 2 * Vector3.dot(direction, V)
  local c = Vector3.dot(V, V) - (RADIUS * RADIUS)

  local discriminant = b*b - 4*a*c

  -- No hit if the discriminant is negative
  if discriminant < 0 then return rgb(0,0,0) end

  local sqrt_discriminant = math.sqrt(discriminant)
  local x1 = (-b + sqrt_discriminant) / (2*a)
  local x2 = (-b - sqrt_discriminant) / (2*a)

  local intercept_distance = math.min(x1, x2)
  local intercept_point = origin + direction * intercept_distance
  -- We intercepted the sphere. Now let's find out what's the normal,
  -- which is the normalized vector from the center of the sphere to the intercept
  local normal = (intercept_point - CENTER):normalize()

  -- Change brightness of pixel based on angle between light_direction and normal
  local brightness = math.min(1, math.max(0.05, Vector3.dot(light_direction, normal)))

  return rgb(
    math.floor(brightness * TINT[1]),
    math.floor(brightness * TINT[2]),
    math.floor(brightness * TINT[3])
  )
end
