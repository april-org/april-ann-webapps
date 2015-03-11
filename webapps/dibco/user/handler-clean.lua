local common          = require "common"
local dibco_common    = require "dibco_common"
local serialize_image = common.serialize_image
local resources       = dibco_common.resources
local nets_path       = dibco_common.nets_path
local examples_path   = dibco_common.examples_path

local NETS_MASK = nets_path .. "/*.net"

function len(v) if type(v) == "string" or type(v) == "table" then return #v else return 0 end end

POST 'clean/#model' {
  function(req, resp, pathParams)
    local body = req.body
    local data = body:match("^[^%c]+%c+[^%c]+%c+[^%c]+%c+(.*)%c+[^%c]+%c+$")
    local tmpname = os.tmpname()
    local f = io.open(tmpname, "w")
    f:write(data)
    f:close()
    local img_dirty = ImageIO.read(tmpname, "png")
    os.remove(tmpname)
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
