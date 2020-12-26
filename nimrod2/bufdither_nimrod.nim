import os
import bufimg
import ditherproc

proc reduce(src, dst: string) =
    var cr = newColorReducer(pf4444)
    var img: ref TBufImg
    new(img)
    img.load(src)
    
    var dither = newPixelDither()
    
    #for i in 1..100:
    dither.ditherImage(img, cr)
    
    
    img.save(dst)
    


echo("usage: src.buf dst.buf")
if paramCount() != 2:
    quit()
    
reduce(paramStr(1), paramStr(2))
echo("finished.")

