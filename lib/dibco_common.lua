local common    = require "common"
local root      = "webapps/dibco"
local resources = root .. "/res"
local bsize     = 256
--
local load_net  =
  common.memoize(function(net_filename)
      local trainer = trainable.supervised_trainer.load(net_filename,
                                                        nil, bsize, nil)
      local params  = image.image_cleaning.getParametersFromString(net_filename,
                                                                   false)
      return trainer,params
  end)

local function clean(net_filename, img_dirty)
  local trainer,params = load_net(net_filename)
  img_dirty = img_dirty:to_grayscale():invert_colors()
  local clock = util.stopwatch()
  clock:reset()
  clock:go()
  local img_clean = image.image_cleaning.clean_image(img_dirty, trainer, params)
  clock:stop()
  print(clock:read())
  collectgarbage("collect")
  return img_clean
end
--
return {
  root = root,
  resources = resources,
  nets_path = resources .. "/nets",
  examples_path = resources .. "/DIRTY",
  clean = clean,
}
