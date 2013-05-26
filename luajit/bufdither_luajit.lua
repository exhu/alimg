-- main

local bufimg = require 'bufimg'
local color_reducer = require 'color_reducer'
local pixel_dither = require 'pixel_dither'

local img = bufimg.BufImg.create()
img:load(arg[1])

local cr = color_reducer.ColorReducer.create()
local pd = pixel_dither.PixelDither.create()


for i = 0, 99 do
    pd:ditherImage(img, cr)
end

img:save(arg[2])

print("finished.")

