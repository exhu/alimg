import strutils
import os

type
    TRGBA* = tuple[r,g,b,a : int]
    
    
    TBufImgBase* = object of TObject ## abstract interface for image access
        
    TBufImg* = object of TBufImgBase
        w, h, sz : int
        buf : seq[byte]


method width*(img : ref TBufImgBase): int = nil
method height*(img : ref TBufImgBase): int = nil

method inBounds*(img : ref TBufImgBase, x, y: int): bool =
    return (x >= 0) and (y >= 0) and (x < img.width) and (y < img.height)

method ofs*(img : ref TBufImgBase, x, y: int): int = nil

method pixel*(img : ref TBufImgBase, ofs : int): TRGBA = nil
method pixel*(img : ref TBufImgBase, ofs : int, color: TRGBA) = nil


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



# --------- tests

var 
    b : ref TBufImg

new(b)
b.load(paramStr(1))
b.save(paramStr(2))

