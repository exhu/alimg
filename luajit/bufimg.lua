

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

local rem = [[
    buf_img * buf_img_load(char * fn);
    void buf_img_save(buf_img * img, char * fn);
    void buf_img_release(buf_img * b);

    //int buf_img_ofs(buf_img * img, int x, int y);
    //bool buf_img_is_in_bounds(buf_img * img, int x, int y);
    
    inline int buf_img_ofs(buf_img * img, int x, int y) {
        return img->w*y*4 + x*4;
    }


    inline bool buf_img_is_in_bounds(buf_img * img, int x, int y) {
        return ((x > 0) && (x < img->w) && (y > 0) && (y < img->h));
    }
    
    //int buf_img_get_width(buf_img * img);
    //int buf_img_get_height(buf_img * img);
    
    //void buf_img_set_pixel(buf_img * img, int ofs, const trgba * v);
    //void buf_img_get_pixel(buf_img * img, int ofs, trgba * out_v);
    
    inline void buf_img_set_pixel(buf_img * img, int ofs, const trgba * v) {
        for(int i = 0; i < 4; ++i)
            img->buf[ofs + i] = v->rgba[i];
    }


    inline void buf_img_get_pixel(buf_img * img, int ofs, trgba * out_v) {
        for(int i = 0; i < 4; ++i)
            out_v->rgba[i] = img->buf[ofs + i];
    }
    
]]


