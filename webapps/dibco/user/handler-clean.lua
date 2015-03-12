local multipart       = require "multipart"
local common          = require "common"
local dibco_common    = require "dibco_common"
local serialize_image = common.serialize_image
local resources       = dibco_common.resources
local nets_path       = dibco_common.nets_path
local examples_path   = dibco_common.examples_path

local NETS_MASK = nets_path .. "/*.net"

POST 'clean/#model' {
  function(req, resp, pathParams)
    local params,files = multipart.parse(req)
    april_list(params)
    local file_info = files.img_dirty_file
    local ext = file_info.name:get_extension()
    local img_dirty = ImageIO.read(file_info.path, ext)
    file_info:clean()
    local nets_list = glob(NETS_MASK)
    local net = nets_list[pathParams.model]
    local img_clean = dibco_common.clean(net, img_dirty)
    ImageIO.write(img_clean, "result.png")
    resp:addHeader("Content-Type", "image/png")
    return serialize_image(img_clean, "png")
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
