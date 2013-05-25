

local ffi = require("ffi")
local bit = require("bit")

module("bufimg")

ffi.cdef[[
typedef struct { uint8_t red, green, blue, alpha; } trgba;
]]


function bytes_to_int(b1, b2, b3, b4)
    if not b4 then error("need four bytes to convert to int",2) end
    local n = b1 + b2*256 + b3*65536 + b4*16777216
    n = (n > 2147483647) and (n - 4294967296) or n
    return n
end

function int_to_bytes(i)
    return {band(i, 255), band(bshr(i, 8), 255), band(bshr(i, 16), 255), band(bshr(i, 24), 255)}  
end
    
function buf_img_load(fn)
    
    local f = io.open(fn, "rb")
    
    local bytes = f:read(4)
    local w = bytes_to_int(bytes[1], bytes[2], bytes[3], bytes[4])
    local bytes = f:read(4)
    local h = bytes_to_int(bytes[1], bytes[2], bytes[3], bytes[4])
    
    local img_sz = w*h*4
    local buf = ffi.new("trgba[?]", img_sz)
    
    local bytes = f:read("*all")
    for i =1, #bytes do
        buf[i-1] = bytes[i]
    end
    
    f:close()    
    
    return {w = w, h = h, buf = buf, img_sz = img_sz}
end
    

function buf_img_save(img, fn)
    local f = io.open(fn, "wb")
    local bytes = int_to_bytes(img.w)
    f:write(bytes)
    local bytes = int_to_bytes(img.h)
    f:write(bytes)
    for i = 0, img.img_sz-1 do
       f:write(img.buf[i]) 
    end
    
    
    f:close()
end




