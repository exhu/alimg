-- main

local bufimg = require 'bufimg'

local img = bufimg.BufImg.create()
img:load(arg[1])
img:save(arg[2])

print("finished.")

