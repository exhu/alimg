module ditherproc;
import bufimg;

public final class ColorReducer {

    alias Downgrade = int function(int a, int cNum) ;
    
    public enum PixelFormat {
        pf4444,
        pf565,
        pf5551
    }
    private Downgrade downgr;

    public this(PixelFormat targetPf) {
        initLookups();
        switch (targetPf) {
            case PixelFormat.pf4444:
                downgr = function int (int a, int cNum) {
                        return lookup4[a];
                    };
                break;

            case PixelFormat.pf565:
                downgr = function int (int a, int cNum) {
                        if (cNum == 1) {
                            return downgrade(a, 6);
                        }
                        if ((cNum == 0) || (cNum == 2)) {
                            return downgrade(a, 5);
                        }

                        return 255;
                    };
                break;

            case PixelFormat.pf5551:
                downgr = function int (int a, int cNum) {
                        if ((cNum >= 0) && (cNum <= 2)) {
                            return downgrade(a, 5);
                        }

                        if (cNum == 3) {
                            return downgrade(a, 1);
                        }
                        return 255;
                    };
                break;
                
           default:
				break;
        }
    }

    public Rgba reduceToClosest(Rgba rgba) {
        Rgba dest;
        foreach(i, e; rgba.elems) {
            dest.elems[i] = downgr(e, cast(int)(i));
        }
        return dest;
    }

    //////////////////
    private static int downgrade(int a, int targetBitCount) {
        int maxv = ((1 << targetBitCount) - 1);
        // ((a / 255.f) * maxv) / maxv * 255.f
        return a * maxv / 255 * 255 / maxv;
    }
    
    private static int [256] lookup4;
    private static void initLookups() {
        for(int i = 0; i < lookup4.length; ++i) {
            lookup4[i] = downgrade(i, 4);
        }
    }
}


public final class PixelDither {
    public void ditherImage(PixelProvider img, ColorReducer cr) {        
        const int w = img.getWidth();        
        const int h = img.getHeight();
        
        for(int y = 0; y < h; ++y)
            for(int x = 0; x < w; ++x) {
                const int ofs = img.ofs(x, y);
                const Rgba rgba = img.getPixelAt(ofs);
                const Rgba rgbaReduced = cr.reduceToClosest(rgba);
                img.setPixelAt(ofs, rgbaReduced);
                const Rgba diff = calcDiff(rgba, rgbaReduced);
                
                //////////////////////////
                // order, apply error to original pixels
                // (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16
                
                correctPixel(img, x-1, y+1, 3, diff);
                correctPixel(img, x, y+1, 5, diff);
                correctPixel(img, x+1, y+1, 1, diff);
                correctPixel(img, x+1, y, 7, diff);
            }
    }
    
    private static void correctPixel(PixelProvider img, int x, int y, int coef, Rgba diff) {
        if (img.inBounds(x, y)) {
            int ofs = img.ofs(x, y);
            const Rgba rgba = img.getPixelAt(ofs);
            const Rgba rgbaTemp = adjustTemp(coef, rgba, diff);
            img.setPixelAt(ofs, rgbaTemp);
        }
    }
    
    private static Rgba adjustTemp(int coef, Rgba rgba, Rgba diff) {
        Rgba temp;
        foreach(i, ref e; temp.elems) {
			e = clamp(rgba.elems[i] + diff.elems[i] * coef / 16);
		}
        return temp;
    }
    
    private static int clamp(int v) {
        if (v < 0)
            return 0;
        
        if (v > 255)
            return 255;
        
        return v;
    }
    
    private static Rgba calcDiff(Rgba rgba, Rgba rgbaReduced) {
        Rgba diff;
        foreach(n, ref e; diff.elems) {
			e = rgba.elems.ptr[n] - rgbaReduced.elems.ptr[n];
		}
        return diff;
    }

}


