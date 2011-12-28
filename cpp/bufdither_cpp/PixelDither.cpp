/* 
 * File:   PixelDither.cpp
 * Author: yur
 * 
 * Created on December 28, 2011, 11:14 AM
 */

#include <cstdlib>

#include "PixelDither.h"

PixelDither::PixelDither() : img(NULL) {
}


PixelDither::~PixelDither() {
}

void PixelDither::ditherImage(PixelProvider * img, ColorReducer * cr) {
    this->img = img;
    const int w = img->getWidth();        
    const int h = img->getHeight();
    IntRGBA rgba;
    IntRGBA rgbaReduced;    

    //const int lastRow = h-1;
    //const int lastColumn = w-1;


    for(int y = 0; y < h; ++y)
        for(int x = 0; x < w; ++x) {
            const int ofs = img->ofs(x, y);
            img->getPixelAt(ofs, rgba);
            cr->reduceToClosest(rgba, rgbaReduced);
            img->setPixelAt(ofs, rgbaReduced);

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
    this->img = NULL;
}


void PixelDither::correctPixel(int x, int y, int coef) {
    if (img->isInBounds(x, y)) {
        const int ofs = img->ofs(x, y);
        img->getPixelAt(ofs, rgbaTemp);
        adjustTemp(coef);
        img->setPixelAt(ofs, rgbaTemp);
    }   
}

void PixelDither::adjustTemp(int coef) {
    for (int i = 0; i < 4; ++i) {
        rgbaTemp[i] = rgbaTemp[i] + rgbaDiff[i] * coef / 16;
        rgbaTemp[i] = clamp(rgbaTemp[i]);
    }
}

int PixelDither::clamp(int v) {
    if (v < 0)
        return 0;
        
    if (v > 255)
        return 255;
        
    return v;
}

void PixelDither::calcDiff(const IntRGBA & rgba, const IntRGBA & rgbaReduced) {
    for(int n = 0; n < 4; ++n) {
        rgbaDiff[n] = rgba[n] - rgbaReduced[n];
    }
}
