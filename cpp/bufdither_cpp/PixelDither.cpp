/* 
 * File:   PixelDither.cpp
 * Author: yur
 * 
 * Created on December 28, 2011, 11:14 AM
 */

#include <cstdlib>

#include "PixelDither.h"

//#include <emmintrin.h>


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
#if 0
void PixelDither::adjustTemp(int coef) {
#if 1
    for (int i = 0; i < 4; ++i) {
        rgbaTemp[i] = rgbaTemp[i] + rgbaDiff[i] * coef / 16;
        rgbaTemp[i] = clamp(rgbaTemp[i]);
    }
#else
    __m128i* prgbaDiff = (__m128i*)&rgbaDiff;
    __m128i* prgbaTemp = (__m128i*)&rgbaTemp;
    
    __m128i minr = {0};
    __m128i maxr = {255};
    
    __m128i ccoef = {coef};
    __m128i mult = _mm_mul_epu32(*prgbaDiff, ccoef);
    __m128i shift = {4};
    mult = _mm_srl_epi32(mult, shift);
    
    *prgbaTemp = _mm_add_epi32(*prgbaTemp, mult);
                
    for (int i = 0; i < 4; ++i) {    
        rgbaTemp[i] = clamp(rgbaTemp[i]);
    }
    
#endif
}

int PixelDither::clamp(int v) {
    if (v < 0)
        return 0;
        
    if (v > 255)
        return 255;
        
    return v;
}
#endif

#if 0
void PixelDither::calcDiff(const IntRGBA & rgba, const IntRGBA & rgbaReduced) {
#if 1
    for(int n = 0; n < 4; ++n) {
        rgbaDiff[n] = rgba[n] - rgbaReduced[n];
    }
#else
    __m128i* prgba = (__m128i*)&rgba[0];
    __m128i* prgbaReduced = (__m128i*)&rgbaReduced;
    __m128i* prgbaDiff = (__m128i*)&rgbaDiff;
    
    *prgbaDiff = _mm_sub_epi32(*prgba, *prgbaReduced);    
   
#endif    
}
#endif
