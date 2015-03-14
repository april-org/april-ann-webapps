-- libraries and aliases
local common          = require "common"
local dibco_common    = require "dibco_common"
local multipart       = require "multipart"
--
local get_mime_from_filename = common.get_mime_from_filename
local md5             = common.md5
local send_file       = common.send_file
local serialize_image = common.serialize_image
local to_json_array   = common.to_json_array
--
local clean_image     = dibco_common.async_clean_image
local clean_path      = dibco_common.clean_path
local dirty_path      = dibco_common.dirty_path
local examples_path   = dibco_common.examples_path
local nets_path       = dibco_common.nets_path
local resources       = dibco_common.resources

-- masks for glob function
local NETS_MASK     = nets_path .. "/*.net"
local EXAMPLES_MASK = examples_path .. "/*.png"

-- applies basename to a list of paths
local function basenames(list)
  return iterator(list):map(string.basename):table()
end

-- /dibco/clean POST method, receives as post parameters the 'model' filename
-- and the image file (it can be an 'example' filename, or a multipart file)
POST 'clean' {
  function(req, resp, pathParams)
    collectgarbage("collect")
    local params,files = multipart.parse(req)
    local model        = params.model
    local example      = params.example
    local name,path,file_info
    if #example == 0 then
      -- in case of no example, the data is taken from a multipart file
      file_info = files.img_dirty_file
      name,path = file_info.name,file_info.path
    else
      -- in other case, the data is taken from the example filename
      name,path = example,table.concat{ examples_path, "/", example }
    end
    -- the extension is used by ImageIO to select the proper driver
    local ext          = name:get_extension()
    local img_dirty    = ImageIO.read(path, ext)
    -- md5 is used to hash the content of the file, generating a generic
    -- filename which contains the model name, the hash and the image name
    local md5sum       = md5(path)
    local hashed_name  = table.concat{ model:remove_extension(), "_",
                                       md5sum, "_", name }
    -- w,h are for <img> tag fields
    local w,h = img_dirty:geometry()
    if file_info then file_info:clean() end
    -- generate the destination path for dirty and clean images
    local dirty_dest = table.concat{ dirty_path, "/", hashed_name }
    local clean_dest = table.concat{ clean_path, "/", hashed_name }
    ImageIO.write(img_dirty, dirty_dest, ext)
    if not io.open(clean_dest) then
      -- execute clean process in a new thread
      local scheduler = Luaw.scheduler
      local thread    = scheduler.startUserThread(function()
          -- only execute cleaning in case the destination path doesn't exists
          local model_path = table.concat{ nets_path, "/", model }
          local img_clean = clean_image(model_path, img_dirty) -- threaded
          ImageIO.write(img_clean, clean_dest)
      end)
    end
    return '/views/view-result.lua', { model=model,
                                       hashed_name=hashed_name,
                                       w=w, h=h }
  end
}

-- returns a JSON array with all the available models
GET 'nets' {
  function(req, resp, pathParams)
    return to_json_array(basenames(glob(NETS_MASK)))
  end
}

-- returns a JSON array with all the available examples
GET 'examples' {
  function(req, resp, pathParams)
    return to_json_array(basenames(glob(EXAMPLES_MASK)))
  end
}

-- returns the webpage with the basic demo UI
GET 'demo' {
  function(req, resp, pathParams)
    collectgarbage("collect")
    local nets_list = glob(NETS_MASK)
    local examples_list = glob(EXAMPLES_MASK)
    local model = {
      nets_list = basenames(nets_list),
      examples_list = basenames(examples_list),
    }
    return '/views/view-demo.lua',model
  end
}

-- returns a clean image given its hashed name
GET 'images/:type/:hash' {
  function(req, resp, pathParams)
    collectgarbage("collect")
    local img_type = pathParams.type
    assert(img_type == "clean" or img_type == "dirty",
           "Incorrect type argument")
    local img_path = img_type=="clean" and clean_path or dirty_path
    local hash = pathParams.hash
    local ext  = hash:get_extension()
    local path = table.concat{ img_path, "/", hash }
    local f    = io.open(path)
    if f then
      resp:setStatus(200)
      send_file(f, resp, get_mime_from_filename(hash))
    else
      resp:setStatus(404)
    end
  end
}

-- returns a clean image given its hashed name
GET 'resources/:name' {
  function(req, resp, pathParams)
    local name = pathParams.name
    resp:setStatus(200)
    send_file(table.concat{ resources, "/", name}, resp,
              get_mime_from_filename(name))
  end
}
