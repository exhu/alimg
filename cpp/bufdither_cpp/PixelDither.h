/* 
 * File:   PixelDither.h
 * Author: yur
 *
 * Created on December 28, 2011, 11:14 AM
 */

#ifndef PIXELDITHER_H
#define	PIXELDITHER_H

#include "ColorReducer.h"

class PixelDither {
public:
    PixelDither();
    
    void ditherImage(PixelProvider * img, ColorReducer * cr);
    
    virtual ~PixelDither();
    
private:
    IntRGBA rgbaDiff;// __attribute__((aligned(16)));
    IntRGBA rgbaTemp;//  __attribute__((aligned(16)));
    PixelProvider * img;
    
    void correctPixel(int x, int y, int coef);
    void adjustTemp(int coef) {
        for (int i = 0; i < 4; ++i) {
            rgbaTemp[i] = rgbaTemp[i] + rgbaDiff[i] * coef / 16;
            rgbaTemp[i] = clamp(rgbaTemp[i]);
        }
    }
    /*static*/ int clamp(int v) {
        if (v < 0)
            return 0;

        if (v > 255)
            return 255;

        return v;
    }
               
    void calcDiff(const IntRGBA & rgba, const IntRGBA & rgbaReduced) {
        for(int n = 0; n < 4; ++n) {
                rgbaDiff[n] = rgba[n] - rgbaReduced[n];
        }
    }


};

#endif	/* PIXELDITHER_H */

