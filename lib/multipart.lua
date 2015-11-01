local TEXT_PLAIN = "text/plain"
-- parses a request which is known to be in multipart/form-data content type
local function parse(req)
  assert(req:isMultipart(), "Expecting multipart request")
  local params = {}
  local files = {}
  local nextPart = iterator(req:multiPartIterator())
  for token, fieldName, fileName, contentType in nextPart do
    token = tostring(token)
    if token == "PART_BEGIN" then
      if fileName then
        -- otherwise it is taken as a binary file stream, write the binary data
        -- into a temporal file
        local size = 0
        local tmpname = os.tmpname()
        local f = io.open(tmpname, "w")
        local token,data = nextPart()
        token = tostring(token)
        while token ~= "PART_END" do
          f:write(data)
          size  = size + #data
          token,data = nextPart()
          token = tostring(token)
        end
        f:close()
        -- store the file data indexed by the form name
        files[fieldName] = {
          name    = fileName,     -- real filename
          path    = tmpname,      -- path to temporary file
          type    = contentType,  -- type of its content (if given)
          size    = size,         -- size in bytes of the data
          clean   = function()
            assert(os.remove(tmpname), "Unable to remove the temporary file")
          end, -- removes temporary file
        }
      else
        -- if the content type is text/plain or not indicated at all, the data is
        -- taken as a key/value pair param
        local _,fieldValue = nextPart()
        params[fieldName] = fieldValue
        token = tostring( (nextPart()) )
        assert(token == "PART_END" or token == "MULTIPART_END",
               "Expected PART_END or MULTIPART_END")
      end
    end
  end
  -- returns two dictionaries with the parsing result
  return params,files
end

return { parse = parse }
