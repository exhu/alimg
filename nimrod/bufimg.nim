import strutils
import os

type
    TRGBA* = array[0..3, int32]
    
    
    TBufImgBase* = object of TObject ## abstract interface for image access
        
    TBufImg* = object of TBufImgBase
        w, h, sz : int32
        buf : seq[uint8]


method width*(img : ref TBufImgBase): int32 = nil
method height*(img : ref TBufImgBase): int32 = nil

method inBounds*(img : ref TBufImgBase, x, y: int32): bool =
    return (x >= 0) and (y >= 0) and (x < img.width) and (y < img.height)

method ofs*(img : ref TBufImgBase, x, y: int32): int32 = nil

method getPixel*(img : ref TBufImgBase, ofs : int32, color: var TRGBA) = nil
method setPixel*(img : ref TBufImgBase, ofs : int32, color: var TRGBA) = nil


# --------

proc load*(img : ref TBufImg, fn : string) =
    stdout.writeln("overriden")
    #load(PBufImgBase(img), fn)
    
    var f = open(fn)
    discard f.readBuffer(addr(img.w), sizeof(img.w))
    discard f.readBuffer(addr(img.h), sizeof(img.h))

    # read buffer bytes
    img.sz = img.w*img.h*4
    newSeq(img.buf, img.sz)
    
    stdout.writeln(inttostr(img.w) & " by " & inttostr(img.h) & " allocated " & inttostr(img.sz))
     
    discard f.readBuffer(img.buf[0].addr, img.sz)
    
    close(f) 

# ----

proc save*(img : ref TBufImg, fn : string) =
    var f = open(fn, fmWrite)
    discard f.writeBuffer(addr(img.w), sizeof(img.w))
    discard f.writeBuffer(addr(img.h), sizeof(img.h))     
    discard f.writeBuffer(img.buf[0].addr, img.sz)
    
    close(f) 

# ---
method width*(img : ref TBufImg): int32 = 
    return img.w
    
    
method height*(img : ref TBufImg): int32 = 
    return img.h
    
    
method ofs*(img : ref TBufImg, x, y: int32): int32 {.inline.}= 
    return y*img.w*4 + x*4
    
    
method getPixel*(img : ref TBufImg, ofs : int32, color: var TRGBA) {.inline.}= 
    for i in countup(0, 3):
        color[i] = int32(img.buf[ofs + i])
        
        
method setPixel*(img : ref TBufImg, ofs : int32, color: var TRGBA) {.inline.}= 
    for i in countup(0, 3):
        let v = uint8(color[i])
        img.buf[ofs+i] = v
        #if v < 0:
        #    stdout.writeln(inttostr(color[i]) & " -> " & $v)

# --------- tests
when false:
    var 
        b : ref TBufImg

    new(b)
    b.load(paramStr(1))
    b.save(paramStr(2))

