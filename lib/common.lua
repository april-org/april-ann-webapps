local tuple = require "tuple"

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
local function to_json_array(it)
  return table.concat{ '[', iterator(it):map(str_fmt):concat(','), ']' }
end

local function memoize(func)
  local cache = {}
  return function(...)
    local t = tuple(...)
    local v = cache[t]
    if not v then v = table.pack( func(...) ) cache[t] = v end
    return table.unpack( v )
  end
end

return {
  serialize_image = serialize_image,
  to_json_array = to_json_array,
  memoize = memoize,
}
