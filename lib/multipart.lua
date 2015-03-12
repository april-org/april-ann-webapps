-- this module parses a request when it is a multipart data, the function
-- 'parse(req)' is exported and performs this operation

local CONTENT_DISPOSITION = "Content-Disposition"
local CONTENT_TYPE = "Content-Type"
local TEXT_PLAIN = "text/plain"
local MULTIPART_FORM_DATA = "multipart/form-data"

-- given a CONTENT_TYPE string, returns the content_type and the boundary
local function split_content_type(str)
  return str:match("([^;]+);%s*boundary=([^%s%c]+)$")
end

-- removes - and % from a string, allowing to use it with Lua patterns
local function escape(str)
  return str:gsub("[%-%%]", { ["-"]="%-", ["%"]="%%" })
end

-- returns an iterator to the given body part of a multipart/form-data request,
-- using the given boundary as separator between parts
local function parts_iterator(body, boundary)
  local boundary = boundary
  local boundary_size = #boundary
  local body_size = #body
  local boundary = escape(boundary)
  return coroutine.wrap(function()
      local data,gmatch
      local _,start = body:find(boundary)
      start = start + 3
      while start < body_size - boundary_size do
        local i,stop = body:find(boundary, start)
        data = body:sub(start, i - 5)
        local headers = {}
        local header_size = 0
        for line in data:gmatch("([^\r\n]*)\r\n") do
          header_size = header_size + 2
          if #line == 0 then break end -- empty line indicates starts of data
          local k,v = line:match("^([^%s]+)%:%s*(.+)$")
          headers[k] = v
          header_size = header_size + #line
        end
        coroutine.yield(headers, data:sub(header_size + 1))
        start = stop + 3
      end
  end)
end

-- returns a field in a request header string like: field="whatever"
local function get_field(field, str)
  return str:match(field .. '%s*%=%s*%"([^%s]+)%"')
end

-- parses a request which is known to be in multipart/form-data content type
local function parse(req)
  local content_type,boundary = split_content_type(req.headers["Content-Type"])
  assert(content_type == MULTIPART_FORM_DATA, "Invalid content type header")
  local params = {}
  local files = {}
  -- for every possible part in the body of the request
  for headers,content in parts_iterator(req.body, boundary) do
    collectgarbage("collect")
    assert(headers[CONTENT_DISPOSITION],
           "Unable to locate content disposition header")
    local name = get_field("name", headers[CONTENT_DISPOSITION])
    local content_type = headers[CONTENT_TYPE]
    if not content_type or content_type == TEXT_PLAIN then
      -- if the content type is text/plain or not indicated at all, the data is
      -- taken as a key/value pair param
      params[name] = content
    else
      -- otherwise it is taken as a binary file stream
      local filename = get_field("filename", headers[CONTENT_DISPOSITION])
      -- write the binary data into a temporal file
      local tmpname = os.tmpname()
      local f = io.open(tmpname, "w")
      f:write(content)
      f:close()
      -- store the file data indexed by the form name
      files[name] = {
        name    = filename,     -- real filename
        path    = tmpname,      -- path to temporary file
        type    = content_type, -- type of its content (if given)
        size    = #content,     -- size in bytes of the data
        clean   = function() os.remove(tmpname) end, -- removes temporary file
      }
    end
  end
  -- returns two dictionaries with the parsing result
  return params,files
end

return { parse = parse }
