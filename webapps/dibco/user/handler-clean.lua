local multipart       = require "multipart"
local common          = require "common"
local dibco_common    = require "dibco_common"
local serialize_image = common.serialize_image
local root            = dibco_common.root
local resources       = dibco_common.resources
local nets_path       = dibco_common.nets_path
local examples_path   = dibco_common.examples_path
local dirty_path      = dibco_common.dirty_path
local clean_path      = dibco_common.clean_path

local NETS_MASK = nets_path .. "/*.net"

POST 'clean/#model' {
  function(req, resp, pathParams)
    local params,files = multipart.parse(req)
    april_list(params)
    local file_info   = files.img_dirty_file
    local name        = file_info.name
    local ext         = name:get_extension()
    local img_dirty   = ImageIO.read(file_info.path, ext)
    local md5sum      = common.md5(file_info.path)
    local hashed_name = table.concat{ md5sum, "_", name }
    resp:setStatus(200)
    resp:appendBody(string.format([[
<html>
<head></head>
<body>
<a href="/dibco/images/dirty/%s">Dirty image</a><br/>
<a href="/dibco/images/clean/%s">Clean image</a><br/>
</body>
</html>
]], hashed_name, hashed_name))
    resp:flush()
    resp:close()
    file_info:clean()
    local dirty_dest = table.concat{ dirty_path, "/", hashed_name }
    local clean_dest = table.concat{ clean_path, "/", hashed_name }
    ImageIO.write(img_dirty, dirty_dest, ext)
    local nets_list = glob(NETS_MASK)
    local net       = nets_list[pathParams.model]
    local img_clean = dibco_common.clean_image(net, img_dirty)
    ImageIO.write(img_clean, clean_dest)
  end
                    }

GET 'demo' {
  function(req, resp, pathParams)
    local nets_list = glob(NETS_MASK)
    local model = {
      nets_list = iterator(nets_list):map(string.basename),
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
