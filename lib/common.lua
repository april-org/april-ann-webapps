package.cpath   = package.cpath .. ";lib/?.so"
local aprilann  = require "aprilann"
local scheduler = require "luaw_scheduler"
local timer_lib = require "luaw_timer"
local tuple     = require "tuple"
--
local CHUNK_SIZE = 4096

local mimes = {
  gif  = "image/gif",
  jpg  = "image/jpeg",
  png  = "image/png",
  txt  = "text/plain",
  html = "text/html",
  css  = "text/css",
  js   = "application/javascript",
}
local function get_mime_from_filename(filename)
  local ext = filename:get_extension()
  return assert(mimes[ext], "Unknown file extension: "..(ext or "nil"))
end

-- receives an APRIL-ANN iterator, the response object and the mime-type
local function send_iterable_data(it, resp, mime)
  assert(class.is_a(it, iterator))
  local mime  = mime or mimes.txt
  local timer = timer_lib.newTimer()
  resp:startStreaming()
  for data in it do
    assert(type(data) == "string", "Needs an iterator of strings")
    resp:appendBody(data)
    timer:sleep(1) -- 1 miliseconds
  end
  resp:flush()
  timer:delete()
  resp:close()
end

local function send_file(f, resp, mime)
  if type(f) == "string" then f = io.open(f) end
  if f then
    resp:setStatus(200)
    send_iterable_data(iterator(f:lines(CHUNK_SIZE)), resp, mime)
  else
    resp:setStatus(404)
  end
end

-- receives an image instance, its type (png, jpg, ...) and returns a string
-- binary representation of the image
local function send_image(img, image_type, resp)
  assert(image_type, "Needs the image type as second argument")
  local out = os.tmpname()
  ImageIO.write(img, out, image_type)
  send_file(out, resp, "image/" .. image_type)
  assert(os.remove(out), "Unable to remove the temporary file")
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
local function async_use_dataset(trainer, tbl)
  assert(tbl,  "Needs a table as argument")
  local input_ds  = assert(tbl.input_dataset, "Needs input_dataset field")
  local output_ds = assert(tbl.output_dataset, "Needs output_dataset field")
  local bsize     = assert(tbl.bunch_size or trainer.bunch_size,
                           "Needs bunch_size field")
  assert(input_ds:numPatterns() == output_ds:numPatterns(),
         "Not compatible number of patterns in given input/output datasets")
  -- timer for thread control
  local timer           = timer_lib.newTimer()
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
  timer:delete()
  return true
end

-- returns the list of exported functions
return {
  async_use_dataset = async_use_dataset,
  get_mime_from_filename = get_mime_from_filename,
  md5 = md5,
  memoize = memoize,
  send_iterable_data = send_iterable_data,
  send_image = send_image,
  send_file = send_file,
  to_json_array = to_json_array,
}
