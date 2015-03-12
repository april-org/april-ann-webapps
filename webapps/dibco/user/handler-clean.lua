local multipart       = require "multipart"
local common          = require "common"
local dibco_common    = require "dibco_common"
local serialize_image = common.serialize_image
local to_json_array   = common.to_json_array
local md5             = common.md5
local root            = dibco_common.root
local resources       = dibco_common.resources
local nets_path       = dibco_common.nets_path
local examples_path   = dibco_common.examples_path
local dirty_path      = dibco_common.dirty_path
local clean_path      = dibco_common.clean_path
local clean_image     = dibco_common.clean_image

local NETS_MASK = nets_path .. "/*.net"
local EXAMPLES_MASK = examples_path .. "/*.png"

local function basenames(list)
  return iterator(list):map(string.basename):table()
end

POST 'clean' {
  function(req, resp, pathParams)
    local params,files = multipart.parse(req)
    local model        = params.model
    local example      = params.example
    local name,path
    if #example == 0 then
      local file_info = files.img_dirty_file
      name = file_info.name
      path = file_info.path
    else
      name = example
      path = table.concat{ examples_path, "/", example }
    end
    local ext          = name:get_extension()
    local img_dirty    = ImageIO.read(path, ext)
    local md5sum       = md5(path)
    local hashed_name  = table.concat{ model:remove_extension(), "_",
                                       md5sum, "_", name }
    local w,h = img_dirty:geometry()
    resp:setStatus(200)
    resp:appendBody(string.format([[
<html>
<head></head>
<body>
Please wait, the process may take a few minutes.
<table>
<tr><td> Model <b> %s </b> </td></tr>
<tr></tr>
<tr><td> <b>Dirty image</b> </td></tr>
<tr><td><a href="/dibco/images/dirty/%s"><img width='%d' height='%d' src="/dibco/images/dirty/%s" /></a></td></tr>
<tr></tr>
<tr><td> <b>Clean image</b> </td></tr>
<tr><td><a href="/dibco/images/clean/%s"><img width='%d' height='%d' src="/dibco/images/clean/%s" /></a></td></tr>
</table>
</body>
</html>
]], model, hashed_name, w, h, hashed_name, hashed_name, w, h, hashed_name))
    resp:flush()
    resp:close()
    if files.img_dirty_file then
      files.img_dirty_file:clean()
    end
    local dirty_dest = table.concat{ dirty_path, "/", hashed_name }
    local clean_dest = table.concat{ clean_path, "/", hashed_name }
    ImageIO.write(img_dirty, dirty_dest, ext)
    if not io.open(clean_dest) then
      local model_path = table.concat{ nets_path, "/", model }
      local img_clean = clean_image(model_path, img_dirty)
      ImageIO.write(img_clean, clean_dest)
    end
  end
}

GET 'nets' {
  function(req, resp, pathParams)
    return to_json_array(basenames(glob(NETS_MASK)))
  end
}

GET 'examples' {
  function(req, resp, pathParams)
    return to_json_array(basenames(glob(EXAMPLES_MASK)))
  end
}

GET 'demo' {
  function(req, resp, pathParams)
    local nets_list = glob(NETS_MASK)
    local examples_list = glob(EXAMPLES_MASK)
    local model = {
      nets_list = basenames(nets_list),
      examples_list = basenames(examples_list),
    }
    return '/views/view-demo.lua',model
  end
}

GET 'images/clean/:hash' {
  function(req, resp, pathParams)
    local hash = pathParams.hash
    local ext  = hash:get_extension()
    local path = table.concat{ clean_path, "/", hash }
    local f    = io.open(path)
    if f then
      resp:setStatus(200)
      resp:addHeader("Content-Type", "image/png")
      resp:appendBody(f:read("*a"))
      resp:flush()
    else
      return "refresh"
    end
  end
}

GET 'images/dirty/:hash' {
  function(req, resp, pathParams)
    local hash = pathParams.hash
    local ext  = hash:get_extension()
    local path = table.concat{ dirty_path, "/", hash }
    local f    = io.open(path)
    if f then
      resp:setStatus(200)
      resp:addHeader("Content-Type", "image/png")
      resp:appendBody(f:read("*a"))
      resp:flush()
    else
      return "refresh"
    end
  end
}
