/* 
 * File:   ColorReducer.cpp
 * Author: yur
 * 
 * Created on December 28, 2011, 10:59 AM
 */
#include <cstdlib>

#include "ColorReducer.h"

int ColorReducer::downgrade4lookup[256];

ColorReducer::ColorReducer(PixelFormat targetPf) : downgr(NULL){
    initlookups();
    switch(targetPf) {
        case pf4444:
            downgr = & ColorReducer::downgrade4444;
            
            break;
            
        case pf565:
            downgr = & ColorReducer::downgrade565;
            break;
            
        case pf5551:
            downgr = & ColorReducer::downgrade5551;
            break;
    }
}


ColorReducer::~ColorReducer() {
}



void ColorReducer::reduceToClosest(const IntRGBA & rgba, IntRGBA & destRGBA) {
    for (int i = 0; i < 4; ++i) {
        destRGBA[i] = downgr(rgba[i], i);
    }
}


int ColorReducer::downgrade(int a, int targetBitCount) {
    int maxv = ((1 << targetBitCount) - 1);
    // ((a / 255.f) * maxv) / maxv * 255.f
    return a * maxv / 255 * 255 / maxv;
}


int ColorReducer::downgrade4444(int a, int cNum) {
    //return downgrade(a, 4);
    return downgrade4lookup[a];
}

int ColorReducer::downgrade565(int a, int cNum) {
    if (cNum == 1) {
        return downgrade(a, 6);
    }
    
    return downgrade(a, 5);    
}

int ColorReducer::downgrade5551(int a, int cNum) {
    if (a == 3)
        return downgrade(a, 1);
    
    return downgrade(a, 5);
}

void ColorReducer::initlookups() {
    for(int i = 0; i < 256; ++i) {
        downgrade4lookup[i] = downgrade(i, 4);
    }
    
}