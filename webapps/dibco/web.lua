package.cpath = package.cpath .. ";lib/?.so"

-- FIXME: This code is producing problems when executing Luaw handlers
--
-- -- To avoid problems between globals in APRIL-ANN and Luaw, this functions
-- -- throws an error in case any global is redefined, except globals which are
-- -- known to be redefined and controlled
-- local function protect_globals_redefinition()
--   local globals = {}
--   setmetatable(_G, {
--                  __index = function(t,k)
--                    return rawget(t, k) or globals[k]
--                  end,
--                  __newindex = function(t,k,v)
--                    local old_v = rawget(t, k) or globals[k]
--                    if old_v == v then return end
--                    if old_v==nil or k=="type" or k=="webapp" then
--                      globals[k] = v
--                    else
--                      error("Unable to redefine global " .. tostring(k))
--                    end
--                  end,
--   })
-- end
-- protect_globals_redefinition()

require "aprilann"

luaw_webapp = {
  resourcePattern = "handler%-.*%.lua$",
  viewPattern = "view%-.*%.lua$",
}
