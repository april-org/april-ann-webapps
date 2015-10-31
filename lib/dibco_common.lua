local common    = require "common"
--
local bsize     = 1024
local root      = "webapps/dibco"
local resources = root .. "/res"
local html_path = root .. "/views/html"

local async_use_dataset = common.async_use_dataset

-- loads a neural network and its params table; note that this function is
-- memoized, so a neural network is only loaded once
local load_net  =
  common.memoize(function(net_filename)
      local trainer = trainable.supervised_trainer.load(net_filename,
                                                        nil, bsize, nil)
      -- use_dataset is used by clean_image function, we need to forece this
      -- call to be async to avoid server blocking
      trainer.use_dataset = async_use_dataset
      local params  = image.image_cleaning.getParametersFromString(net_filename,
                                                                   false)
      return trainer,params
  end)

-- receives a network filename, a dirty image instance and returns an image
-- instance which is the clean version of the given dirty image
local function async_clean_image(net_filename, img_dirty)
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

-- functions export
return {
  async_clean_image = async_clean_image,
  clean_path = resources .. "/CLEAN",
  dirty_path = resources .. "/DIRTY",
  examples_path = resources .. "/EXAMPLES",
  resources = resources,
  root = root,
  nets_path = resources .. "/nets",
  html_path = html_path,
}
