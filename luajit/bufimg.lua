local ffi = require("ffi")
local bit = require("bit")

local M = {    
}


ffi.cdef[[
void *fopen (const char * __filename,
		    const char * __modes);
int fclose (void *__stream);
size_t fread (void *__restrict __ptr, size_t __size,
		     size_t __n, void *__restrict __stream);
size_t fwrite (const void *__restrict __ptr, size_t __size,
		      size_t __n, void *__restrict __s);

]]

-- typedef int32_t[4] rgba_44;

local BufImg = {}
M.BufImg = BufImg

function BufImg.create()
    local inst = {}
    local m = {__index=BufImg}
    setmetatable(inst, m)
    return inst
end

function BufImg:isInBounds(x,y)
    return ((x > 0) and (x < self.w) and (y > 0) and (y < self.h))
end


function BufImg:ofs(x,y)
    return self.w*y*4 + x*4
end

function BufImg:load(fn)
    if fn == nil then error("can't open nil") end

    local C = ffi.C
    local f = C.fopen(fn, "rb")
    
    local wh = ffi.new("int32_t[1]")
    C.fread(wh, 4, 1, f)
    self.w = wh[0]
    C.fread(wh, 4, 1, f)
    self.h = wh[0]
    self.sz = self.w * self.h * 4
    self.buf = ffi.new("uint8_t[?]", self.sz)
    C.fread(self.buf, self.sz, 1, f)
    C.fclose(f)
    
    print("loaded image "..self.w.."x"..self.h.." sz = "..self.sz)
end

function BufImg:save(fn)
    if fn == nil then error("can't open nil") end
        
    local f = ffi.C.fopen(fn, "wb")
    local C = ffi.C
    local wh = ffi.new("int32_t[1]")
    wh[0] = self.w
    C.fwrite(wh, 4, 1, f)
    wh[0] = self.h
    C.fwrite(wh, 4, 1, f)
    C.fwrite(self.buf, self.sz, 1, f)
    C.fclose(f)
end

function BufImg:setPixelAt(byteofs, rgba)
    for i = 0, 3 do
        self.buf[byteofs + i] = rgba[i]
    end
end

function BufImg:getPixelAt(byteofs, rgba)
    for i = 0, 3 do
        rgba[i] = self.buf[byteofs + i]
    end
end

--[[

ffi.cdef
typedef struct { uint8_t red, green, blue, alpha; } trgba;





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

--]]

-- export module:
return M

