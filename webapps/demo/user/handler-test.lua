local common = require "demo_common"

GET 'test' {
  function(req, resp, pathParams)
    local img = ImageIO.read(common.resources .. "/activations_rnn.png"):to_grayscale()
    resp:addHeader("Content-Type", "image/png")
    return serialize_image(img, "png")
  end
           }
