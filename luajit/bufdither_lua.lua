-- main

local bufimg = require("bufimg")

local img = bufimg_load(arg[1])
bufimg.bufimg_save(img, arg[2])

print("finished.")

