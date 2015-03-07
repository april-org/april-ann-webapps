local function serialize_image(img, image_type)
  assert(image_type, "Needs the image type as second argument")
  local out = os.tmpname()
  ImageIO.write(img, out, image_type)
  local f   = io.open(out)
  local bin = f:read("*a")
  f:close()
  assert(os.remove(out))
  return bin
end

return {
  serialize_image = serialize_image,
}
