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
    void adjustTemp(int coef);
    static int clamp(int v);
    void calcDiff(const IntRGBA & rgba, const IntRGBA & rgbaReduced);

};

#endif	/* PIXELDITHER_H */

