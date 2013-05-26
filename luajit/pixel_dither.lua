local ffi = require 'ffi'

local M = {}

local PixelDither = {}
M.PixelDither = PixelDither

local ct = ffi.typeof("int32_t[?]")

function PixelDither.create()
    local inst = {rgbaDiff = ct(4), rgbaTemp = ct(4)}
    setmetatable(inst, {__index = PixelDither})
    return inst
end


function PixelDither:calcDiff(rgba, rgbaReduced)
    for n = 0, 3 do
        self.rgbaDiff[n] = rgba[n] - rgbaReduced[n]
    end
end


local function clamp(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return v
end


function PixelDither:adjustTemp(coef)
    for i = 0, 3 do
        self.rgbaTemp[i] = self.rgbaTemp[i] + self.rgbaDiff[i] * coef / 16
        self.rgbaTemp[i] = clamp(self.rgbaTemp[i])
    end
end


-- img = bufimg, cr = ColorReducer
function PixelDither:ditherImage(img, cr)
    self.img = img
    local w, h = img.w, img.h    
    local rgba, rgbaReduced = ct(4), ct(4)
    
    for y = 0, h-1 do
        for x = 0, w-1 do
            ofs = img:ofs(x,y)
            img:getPixelAt(ofs, rgba)
            cr:reduceToClosest(rgba, rgbaReduced)
            img:setPixelAt(ofs, rgbaReduced)
            
            self:calcDiff(rgba, rgbaReduced)
            
            self:correctPixel(x-1, y+1, 3)
            self:correctPixel(x, y+1, 5)
            self:correctPixel(x+1, y+1, 1)
            self:correctPixel(x+1, y, 7)            
        end
    end
    
    self.img = nil    
end


function PixelDither:correctPixel(x,y,coef)
    if self.img:isInBounds(x,y) then
        local ofs = self.img:ofs(x,y)
        self.img:getPixelAt(ofs, self.rgbaTemp)
        self:adjustTemp(coef)
        self.img:setPixelAt(ofs, self.rgbaTemp)
    end
end


--------------

return M
