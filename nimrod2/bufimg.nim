type
    TRGBA* = array[0..3, int32]
    TBufImg* = object
        w, h, sz: int32
        buf: seq[uint8]


proc inBounds*(img : ref TBufImg, x, y: int32): bool {.inline.}=
    return (x >= 0) and (y >= 0) and (x < img.w) and (y < img.h)


# --------

proc load*(img : ref TBufImg, fn : string) =
    echo("overriden")
    #load(PBufImgBase(img), fn)
    
    var f = open(fn)
    discard f.readBuffer(addr(img.w), sizeof(img.w))
    discard f.readBuffer(addr(img.h), sizeof(img.h))

    # read buffer bytes
    img.sz = img.w*img.h*4
    newSeq(img.buf, img.sz)
    
    echo("{img.w} by {img.h} allocated {img.sz}")
     
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
proc width*(img : ref TBufImg): int32 {.inline.} =
    return img.w
    
    
proc height*(img : ref TBufImg): int32 {.inline.} =
    return img.h
    
    
proc ofs*(img : ref TBufImg, x, y: int32): int32 {.inline.}= 
    return y*img.w*4 + x*4
    
    
proc getPixel*(img : ref TBufImg, ofs : int32, color: var TRGBA) {.inline.}= 
    for i in 0..3:
        color[i] = int32(img.buf[ofs + i])
        
        
proc setPixel*(img : ref TBufImg, ofs : int32, color: TRGBA) {.inline.}= 
    for i in 0..3:
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

