import bufimg
import strutils

type
    TPixelFormat* = enum
        pf4444, pf565, pf5551
        
    TDowngradeProc = proc(a, cNum : int): int
    
    TColorReducer* = object of TObject
        downgr: TDowngradeProc
        
    TPixelDither* = object of TObject
        rgbaDiff, rgbaTemp: TRGBA
        img: ref TBufImgBase
        
        
# ------ TColorReducer
var
  down4lookup: array[0..255, int]


proc downgrade4444(a, cNum : int) : int  =
    result = down4lookup[a]


proc newColorReducer*(pf : TPixelFormat) : ref TColorReducer =
    new(result)
    if pf == pf4444:
        result.downgr = downgrade4444
    else:
        quit "only pf4444 is supported!"
    
     
proc reduceToClosest*(red: ref TColorReducer, rgba: TRGBA): TRGBA =
    for i in countup(0, 3):
        result[i] = red.downgr(rgba[i], i)
    

# ------ TPixelDither

proc newPixelDither*(): ref TPixelDither =
    new(result)
    
    
proc clamp(v : int) : int =
    if v < 0:
        return(0)

    if v > 255:
        return(255)

    result = v


proc calcDiff(pd: ref TPixelDither, rgba: TRGBA, rgbaReduced: TRGBA) =
  for i in countup(0,3):
      pd.rgbaDiff[i] = rgba[i] - rgbaReduced[i]


proc adjustTemp(pd: ref TPixelDither, coef: int) =
  for i in countup(0,3):
    pd.rgbaTemp[i] = clamp(pd.rgbaTemp[i] + pd.rgbaDiff[i] * coef div 16)


proc correctPixel(pd: ref TPixelDither, x, y, coef: int) =
   let ofs = pd.img.ofs(x, y)
   pd.rgbaTemp = pd.img.pixel(ofs)
   pd.adjustTemp(coef)
   pd.img.pixel(ofs, pd.rgbaTemp)

  
when false:  
    proc dumpRGBA(rgba: TRGBA) =
        stdout.write("(" & inttostr(rgba[0]) & ", " & inttostr(rgba[1]) & ", " & inttostr(rgba[2]) & ", " & inttostr(rgba[3]) & ")")
    
    
proc ditherImage*(pd: ref TPixelDither, img: ref TBufImgBase, cr: ref TColorReducer) =
    pd.img = img
    let lastCol = img.width-1
    let lastRow = img.height-1
    
    for y in countup(0, lastRow):
        for x in countup(0, lastCol):
            let ofs = img.ofs(x,y)
            let rgba = img.pixel(ofs)
            let rgbaReduced = cr.reduceToClosest(rgba)
            
            #dumpRGBA(rgba)
            #stdout.write(" -> ")
            #dumpRGBA(rgbaReduced)
            #stdout.writeln("") 
            
            img.pixel(ofs, rgbaReduced)
            
            pd.calcDiff(rgba, rgbaReduced)
    
            # order, apply error to original pixels
            # (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16

            let notLastRow = (y < lastRow)
            let notLastCol = (x < lastCol)
            
            when true:
            
                if notLastRow:
                    if x > 0:
                        pd.correctPixel(x-1, y+1, 3)

                    pd.correctPixel(x, y+1, 5)

                    if notLastCol:
                       pd.correctPixel(x+1, y+1, 1)

                if notLastCol:
                   pd.correctPixel(x+1, y, 7)

    pd.img = nil
    
    

# -----

#function downgrade(a, targetBitCount : integer) : integer;inline;
#var
#  maxv : integer;
#begin
#  maxv := ((1 shl targetBitCount) - 1);
#  result := (((a * maxv) div 255) * 255) div maxv;
#end;

proc downgrade4(a : int) : int =
  result = a * 15 div 255 * 17

proc initlookup4 = 
    for i in countup(0, 255):
        down4lookup[i] = downgrade4(i)
        #stdout.writeln($i & " -> " & $down4lookup[i])
    #stdout.writeln "initialized lookup"
          
# -------
initlookup4()

