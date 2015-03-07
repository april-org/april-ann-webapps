local common          = require "common"
local demo_common     = require "demo_common"
local serialize_image = common.serialize_image
local resources       = demo_common.resources

GET 'test' {
  function(req, resp, pathParams)
    local img = ImageIO.read(resources .. "/activations_rnn.png"):to_grayscale()
    resp:addHeader("Content-Type", "image/png")
    return serialize_image(img, "png")
  end
           }
