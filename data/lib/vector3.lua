-- Vector3 implementation
local Vector3 = {}
Vector3.mt = {}

-- Enables method calls on instances
Vector3.mt.__index = Vector3.mt

local function is_vector3(var)
  return getmetatable(var) == Vector3.mt
end

-- `==` operator overload
Vector3.mt.__eq = function(a,b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to equate a Vector3 with a non-Vector3 value", 2)
  end

  return a.x == b.x and a.y == b.y and a.z == b.z
end

-- `+` operator overload
Vector3.mt.__add = function(a,b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to add a Vector3 with a non-Vector3 value", 2)
  end
  return Vector3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- `-` operator overload
Vector3.mt.__sub = function(a, b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to subtract a Vector3 with a non-Vector3 value", 2)
  end
  return Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- `*` operator overload
Vector3.mt.__mul = function(a, b)
  -- Can multiply with either a Vector3 or a scalar
  local a_is_vec = is_vector3(a)
  local b_is_vec = is_vector3(b)

  -- Scalar * Vector3
  if type(a) == "number" and b_is_vec then
    return Vector3.new(a * b.x, a * b.y, a * b.z)
  end

  -- Vector3 * Scalar
  if a_is_vec and type(b) == "number" then
    return Vector3.new(a.x * b, a.y * b, a.z * b)
  end

  -- Vector3 * Vector3
  if a_is_vec and b_is_vec then
    return Vector3.new(a.x * b.x, a.y * b.y, a.z * b.z)
  end

  error("invalid operands for Vector3 multiplication", 2)
end

-- `/` operator overload
Vector3.mt.__div = function(a, b)
  if not is_vector3(a) then
    error("attempt to divide a non-Vector3 value", 2)
  end

  if is_vector3(b) then
    return Vector3.new(a.x / b.x, a.y / b.y, a.z / b.z)
  elseif type(b) == "number" then
    return Vector3.new(a.x / b, a.y / b, a.z / b)
  else 
    error("attempt to divide a Vector3 with an invalid value", 2)
  end
end

-- Unary `-` operator overload
Vector3.mt.__unm = function(a)
  if not is_vector3(a) then
    error("attempt to negate a non-Vector3 value", 2)
  end
  return Vector3.new(-a.x, -a.y, -a.z)
end

-- `tostring` overload; allows print(vec) to just work
Vector3.mt.__tostring = function(vec)
  return "{" .. "x=" .. tostring(vec.x) .. ", y=" .. tostring(vec.y) .. ", z=" .. tostring(vec.z) .. "}"
end

-- Public methods

---- Class static methods

function Vector3.is_instance(variable)
  return is_vector3(variable)
end

-- Create a new Vector3
function Vector3.new(x, y, z)
  local vec = {
    x = x,
    y = y,
    z = z,
  }
  setmetatable(vec, Vector3.mt)
  return vec
end

-- Create a copy of a Vector3
function Vector3.copy(vec)
  return Vector3.new(vec.x, vec.y, vec.z)
end

-- Compute the dot product of two Vector3
function Vector3.dot(a, b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to dot product a Vector3 with a non-Vector3 value", 2)
  end
  return a.x * b.x + a.y * b.y + a.z * b.z
end

function Vector3.manhattan_distance(a,b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to compute Manhattan distance with a non-Vector3 value", 2)
  end
  return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z)
end

function Vector3.distance(a,b)
  if not is_vector3(a) or not is_vector3(b) then
    error("attempt to compute Euclidean distance with a non-Vector3 value", 2)
  end
  return (b - a):length()
end

function Vector3.cross(a, b)
  -- see https://en.wikipedia.org/wiki/Cross_product#Computing
  return Vector3.new(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  )
end

function Vector3.rotate(vec, axis, angle)
  -- axis MUST be normalized, otherwise this doesn't work.
  -- see https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
  local c = math.cos(angle)
  local s = math.sin(angle)
  local dot = Vector3.dot(axis, vec)
  local cross = Vector3.cross(axis, vec)

  return vec * c + cross * s + axis * dot * (1 - c)
end

---- Class instance methods

-- Return the magnitude squared of the vector (avoids square root)
function Vector3.mt:length_squared()
  return self.x * self.x + self.y * self.y + self.z * self.z
end

-- Return the magnitude of the vector
function Vector3.mt:length()
  return math.sqrt(self:length_squared())
end

-- Return a normalized (length == 1) version of the vector
function Vector3.mt:normalize()
  local length = self:length()
  if length == 0 then
    error("cannot normalize zero-length vector", 2)
  end
  return Vector3.copy(self) / length
end

-- Make a copy of this vector
function Vector3.mt:copy()
  return Vector3.copy(self)
end

-- Return a floored copy of this vector
function Vector3.mt:floor()
  return Vector3.new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

-- Module definition


-- Vector3 constants accessible like this:
-- local myvec = Vector3.ZERO
local VECTOR3_NAMED_CONSTANTS = {
  ZERO    = Vector3.new( 0,  0,  0),
  ONE     = Vector3.new( 1,  1,  1),
  UP      = Vector3.new( 0, -1,  0),
  DOWN    = Vector3.new( 0,  1,  0),
  LEFT    = Vector3.new(-1,  0,  0),
  RIGHT   = Vector3.new( 1,  0,  0),
  FORWARD = Vector3.new( 0,  0,  1),
  BACK    = Vector3.new( 0,  0, -1),
}

setmetatable(Vector3, {
  -- __index runs when we try to access a key that doesn't exist on the table
  __index = function(table, key)
    local c = VECTOR3_NAMED_CONSTANTS[key]
    -- Return a copy of the constant named vector
    if c then return Vector3.copy(c) end
  end
})

-- Test the module when it's launched as main
if (...) == nil then
  local zero = Vector3.ZERO

  -- Mutate Vector3.ZERO
  zero.x = 2
  zero.y = 2
  zero.z = 2

  -- Check that we didn't change the output of Vector3.ZERO
  local second_zero = Vector3.ZERO
  assert(second_zero.x == 0 and second_zero.y == 0 and second_zero.z == 0)

  -- Test vectors
  local v1 = Vector3.new(1, 2, 3)
  local v2 = Vector3.new(2, 4, 6)
  local v3 = Vector3.new(3, 6, 9)

  -- Check tostring()
  assert(tostring(v1) == "{x=1, y=2, z=3}")

  -- Check addition
  local sum = v1 + v2
  assert(sum.x == 3 and sum.y == 6 and sum.z == 9)

  -- Check subtraction
  local diff = v2 - v1
  assert(diff.x == 1 and diff.y == 2 and diff.z == 3)

  -- Check scalar multiplication
  local product_scalar_left = v1 * 3
  assert(product_scalar_left.x == 3 and product_scalar_left.y == 6 and product_scalar_left.z == 9)

  local product_scalar_right = 3 * v1
  assert(product_scalar_right.x == 3 and product_scalar_right.y == 6 and product_scalar_right.z == 9)

  -- Check component-wise multiplication
  local product = v1 * v2
  assert(product.x == 2 and product.y == 8 and product.z == 18)

  -- Check division
  local quotient_scalar = v2 / 2
  assert(quotient_scalar.x == 1 and quotient_scalar.y == 2 and quotient_scalar.z == 3)

  local quotient_vec = v3 / v1
  assert(quotient_vec.x == 3 and quotient_vec.y == 3 and quotient_vec.z == 3)

  -- Check dot product
  local dot_product = Vector3.dot(v1, v2)
  -- 1*2 + 2*4 + 3*6 = 2 + 8 + 18 = 28
  assert(dot_product == 28)

  -- Check length (use proper 3D vector)
  local magnitude = Vector3.new(2, 3, 6):length()
  assert(magnitude == 7) -- 2^2 + 3^2 + 6^2 = 49

  -- Check length_squared
  local len_sq = Vector3.new(2, 3, 6):length_squared()
  assert(len_sq == 49)

  -- Check normalize
  local normalized = Vector3.new(2, 0, 0):normalize()
  assert(math.abs(normalized:length() - 1) < 0.0001)
  assert(math.abs(normalized.x - 1) < 0.0001)

  -- Check chaining
  local chained = (v1 + v2) * 2
  assert(chained.x == 6 and chained.y == 12 and chained.z == 18)

  -- Check unary minus
  local negated = -v1
  assert(negated.x == -1 and negated.y == -2 and negated.z == -3)

  -- Check floor
  local float_vector = Vector3.new(1.8, 2.9, 3.1)
  local floored = float_vector:floor()
  assert(floored.x == 1 and floored.y == 2 and floored.z == 3)

  -- Check distance
  local dist = Vector3.distance(Vector3.new(0,0,0), Vector3.new(0,3,4))
  assert(dist == 5)

  -- Check Manhattan distance
  local manhattan = Vector3.manhattan_distance(Vector3.new(1,2,3), Vector3.new(4,6,9))
  assert(manhattan == 13) -- |3| + |4| + |6|

  -- Check error cases
  local ok

  ok = pcall(function() return v1 + 5 end)
  assert(not ok, "adding a scalar to a Vector3 should throw")

  ok = pcall(function() return v1 * "hello" end)
  assert(not ok, "multiplying a Vector3 by a string should throw")

  print("Vector3: all tests passed !")
end

return Vector3
