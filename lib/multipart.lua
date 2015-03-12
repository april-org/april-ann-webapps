local CONTENT_DISPOSITION = "Content-Disposition"
local CONTENT_TYPE = "Content-Type"
local TEXT_PLAIN = "text/plain"

local function split_content_type(str)
  return str:match("([^;]+);%s*boundary=([^%s%c]+)$")
end

local function escape(str)
  return str:gsub("[%-%%]", { ["-"]="%-", ["%"]="%%" })
end

local function parts_iterator(body, boundary)
  local boundary = boundary .. "\r\n"
  local boundary_size = #boundary
  local body_size = #body
  local boundary = escape(boundary)
  return coroutine.wrap(function()
      local data,gmatch
      local _,start = body:find(boundary)
      start = start + 1
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
        start = stop + 1
      end
  end)
end

local function get_field(field, str)
  return str:match(field .. '%s*%=%s*%"([^%s]+)%"')
end

local function parse(req)
  local content_type,boundary = split_content_type(req.headers["Content-Type"])
  local params = {}
  local files = {}
  for headers,content in parts_iterator(req.body, boundary) do
    collectgarbage("collect")
    assert(headers[CONTENT_DISPOSITION])
    local name = get_field("name", headers[CONTENT_DISPOSITION])
    local content_type = headers[CONTENT_TYPE]
    if not content_type or content_type == TEXT_PLAIN then
      params[name] = content
    else
      local filename = get_field("filename", headers[CONTENT_DISPOSITION])
      local tmpname = os.tmpname()
      local f = io.open(tmpname)
      f:write(content)
      f:close()
      files[name] = {
        name    = filename,
        path    = tmpname,
        type    = content_type,
        size    = #content,
        clean   = function() os.remove(tmpname) end,
      }
    end
  end
  return params,files
end

return { parse = parse }
