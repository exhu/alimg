module ditherproc;
import bufimg;

class ColorReducer {

    alias int function(int a, int cNum) Downgrade;
    

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

    public final void reduceToClosest(ref RGBA rgba, ref RGBA destRGBA) {
        for (int i = 0; i < 4; ++i) {
            destRGBA[i] = downgr(rgba[i], i);
        }
    }

    //////////////////
    private static int downgrade(int a, int targetBitCount) {
        int maxv = ((1 << targetBitCount) - 1);
        // ((a / 255.f) * maxv) / maxv * 255.f
        return a * maxv / 255 * 255 / maxv;
    }
    
    private static int [256] lookup4;
    private static void initLookups() {
        for(int i = 0; i < 256; ++i) {
            lookup4[i] = downgrade(i, 4);
        }
    }
}


public class PixelDither {
    private RGBA rgbaDiff;
    private PixelProvider img;
    private RGBA rgbaTemp;
    
    public void ditherImage(PixelProvider img, ColorReducer cr) {        
        this.img = img;
        const int w = img.getWidth();        
        const int h = img.getHeight();
        RGBA rgba;
        RGBA rgbaReduced;
        int ofs;
        
        //final int lastRow = h-1;
        //final int lastColumn = w-1;
        
        
        for(int y = 0; y < h; ++y)
            for(int x = 0; x < w; ++x) {
                ofs = img.ofs(x, y);
                img.getPixelAt(ofs, rgba);
                cr.reduceToClosest(rgba, rgbaReduced);
                img.setPixelAt(ofs, rgbaReduced);
                
                
                calcDiff(rgba, rgbaReduced);
                
                //////////////////////////
                // order, apply error to original pixels
                // (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16
                
                
                correctPixel(x-1, y+1, 3);
                correctPixel(x, y+1, 5);
                correctPixel(x+1, y+1, 1);                
                correctPixel(x+1, y, 7);                                 
            }
        
        
        // no longer need img
        this.img = null;
    }
    
    private void correctPixel(int x, int y, int coef) {
        if (img.isInBounds(x, y)) {
            int ofs = img.ofs(x, y);
            img.getPixelAt(ofs, rgbaTemp);
            adjustTemp(coef);
            img.setPixelAt(ofs, rgbaTemp);
        }
    }
    
    private void adjustTemp(int coef) {
        for (int i = 0; i < 4; ++i) {
            rgbaTemp[i] = rgbaTemp[i] + rgbaDiff[i] * coef / 16;
            rgbaTemp[i] = clamp(rgbaTemp[i]);
        }            
    }
    
    private static int clamp(int v) {
        if (v < 0)
            return 0;
        
        if (v > 255)
            return 255;
        
        return v;
    }
    
    private void calcDiff(ref RGBA rgba, ref RGBA rgbaReduced) {
        for(int n = 0; n < 4; ++n) {
            rgbaDiff[n] = rgba[n] - rgbaReduced[n];
        }
    }

}


