if #arg < 4 then
  print("Usage: "..arg[0].." list src_dir dst_dir mlpFile [bunchsize] [num_processes]")
  do return end
end

print (#arg)
list_file_name = arg[1]
src_dir = arg[2]
dst_dir = arg[3]
mlpFile = arg[4]
bunchsize = tonumber(arg[5]) or 32
num_processes = tonumber(arg[6]) or 4

--mlpClean = ann.mlp.all_all.load(mlpFile)


print (list_file_name)
trainer = trainable.supervised_trainer.load(mlpFile, nil, bunchsize)
trainer:build()
--trainer = trainable.supervised_trainer(mlpClean,nil, bunchsize)
print("Dst dir", dst_dir)
os.execute("mkdir -p " .. dst_dir)

params = image.image_cleaning.getParametersFromString(mlpFile, false)

for i, v in pairs(params) do
  print("param",i, v)
end


file_list={}
for line in io.lines(list_file_name) do
    table.insert(file_list, line)
end

parallel_foreach(num_processes, file_list, function(line)
    src_name = src_dir.."/"..line..".png"
    dst_name = dst_dir.."/"..line..".png"
    printf("%s -> %s\n", src_name, dst_name)
    img = ImageIO.read(src_name):to_grayscale():invert_colors() --:add_rows(1,1,1.0)
    
    --    imgClean = image.image_cleaning.apply_filter_histogram(img, neighbors, levels, radius, trainer)
    local clock = util.stopwatch()
    clock:reset()
    clock:go()
    
    imgClean = image.image_cleaning.clean_image(img, trainer, params)
    --imgClean:threshold(0.1,0.9)
    ImageIO.write(imgClean, dst_name)
   
    imageClean = nil
    img = nil
    cpu, wall = clock:read()
    printf("Done! %s -> %s (%f %f)\n", src_name, dst_name, cpu, wall)
    collectgarbage("collect")
end)

