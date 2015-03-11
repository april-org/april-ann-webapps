local trainer = util.deserialize(arg[1])
local outname = arg[2]
local ndims = tonumber(arg[3] or 3)

local function reverse_table(t)
  return iterator.range(#t,1,-1):map(function(i) return t[i] end):table()
end

local function convert_weights(w, K)
  assert(#ndims == #K, "Incorrect number of dimensions given as 3rd argument")
  local H = w:dim(1)
  local reversed_K = reverse_table(K)
  local S = iterator(K):prod()
  for h=1,H do
    local row = w:select(1,h)
    local converted_row = row:clone():rewrap(table.unpack(reversed_K)):
    transpose():clone():rewrap(S)
    row:copy(converted_row)
  end
  return w
end

local function convert(trainer)
  local stack = trainer:get_component()
  local t = {}
  while stack:size() > 0 do
    t[stack:size()] = stack:get(stack:size()) stack:pop()
  end
  for i=1,#t do
    if class.is_a(t[i], ann.components.rewrap) then
      stack:push(t[i])
      stack:push(ann.components.transpose{ name="transpose1",
					   dims=iterator.range(2,ndims):table()
					 })
    elseif class.is_a(t[i], ann.components.flatten) then
      stack:push(ann.components.transpose{ name="transpose2" })
      stack:push(t[i])
    else
      stack:push(t[i])
    end
  end
  trainer:build()
  for name,c in trainer:iterate_components("conv%-w.") do
    local wname = c:get_weights_name()
    local w = trainer:weights(wname)
    local K = c:get_kernel_shape()
    convert_weights(w, K)
  end
  return trainer
end

convert(trainer)

trainer:save(outname)
