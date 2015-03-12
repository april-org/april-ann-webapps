local tuple = require "tuple"

-- receives an image instance, its type (png, jpg, ...) and returns a string
-- binary representation of the image
local function serialize_image(img, image_type)
  assert(image_type, "Needs the image type as second argument")
  local out = os.tmpname()
  ImageIO.write(img, out, image_type)
  local f   = io.open(out)
  local bin = f:read("*a")
  f:close()
  assert(os.remove(out))
  return bin
end

local str_fmt = bind(string.format, "%q")
-- converts to JSON array a Lua table array
local function to_json_array(it)
  return table.concat{ '[', iterator(it):map(str_fmt):concat(','), ']' }
end

-- applies memoization to a function
local function memoize(func)
  local cache = {}
  return function(...)
    local t = tuple(...)
    local v = cache[t]
    if not v then v = table.pack( func(...) ) cache[t] = v end
    return table.unpack( v )
  end
end

-- computes MD5 by using shell commands
local function md5(path)
  local f = assert(io.popen("md5sum " .. path, "r"))
  local md5sum = f:read("*l"):match("([^%s]+)")
  f:close()
  return md5sum
end

-- returns the list of exported functions
return {
  serialize_image = serialize_image,
  to_json_array = to_json_array,
  memoize = memoize,
  md5 = md5,
}
