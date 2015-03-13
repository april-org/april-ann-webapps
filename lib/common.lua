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
  local md5sum = assert(f:read("*l")):match("([^%s]+)")
  f:close()
  return md5sum
end

-- receives a table with the fields: input_dataset, output_dataset, trainer
local function use_dataset_thread(tbl)
  assert(tbl,  "Needs a table as argument")
  local input_ds  = assert(tbl.input_dataset, "Needs input_dataset field")
  local output_ds = assert(tbl.output_dataset, "Needs output_dataset field")
  local trainer   = assert(tbl.trainer, "Needs trainer field")
  local bsize     = assert(tbl.bunch_size or trainer.bunch_size,
                           "Needs bunch_size field")
  assert(input_ds:numPatterns() == output_ds:numPatterns(),
         "Not compatible number of patterns in given input/output datasets")
  -- timer for thread control
  local timer           = Luaw.newTimer()
  local net             = trainer:get_component()
  local output_ds_token = dataset.token.wrapper(output_ds)
  local iterator_conf   = { datasets = { input_ds }, bunch_size = bsize }
  local nump,n = input_ds:numPatterns(),0
  for pat,indexes in trainable.dataset_multiple_iterator(iterator_conf) do
    collectgarbage("collect")
    net:reset()
    local out = net:forward(pat)
    output_ds_token:putPatternBunch(indexes, out)
    n = n + #indexes
    -- print(n/nump)
    timer:sleep(1) -- 1 miliseconds
  end
  return true
end

-- returns the list of exported functions
return {
  serialize_image = serialize_image,
  to_json_array = to_json_array,
  memoize = memoize,
  md5 = md5,
  use_dataset_thread = use_dataset_thread,
}
