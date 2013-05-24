-- buffer image

local ffi = require("ffi")
ffi.cdef[[
typedef struct { int32_t red, green, blue, alpha; } rgba_44;
]]

BufImg = {
}

function BufImg.create()
    local inst = {}
    local m = {__index=BufImg}
    setmetatable(inst, m)
    return inst
end

function BufImg:w()
    return self.w
end

function BufImg:h()
    return self.h
end

function BufImg:ofs(x,y)
    return self.w*y*4 + x*4
end

function BufImg:load(fn)
    self.buf = ffi.new("uint8_t[?]", sz)
end

function BufImg:setPixelAt(byteofs, rgba)
end

function BufImg:getPixelAt(byteofs, rgba)
end
