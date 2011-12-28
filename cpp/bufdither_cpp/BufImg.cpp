/* 
 * File:   BufImg.cpp
 * Author: yur
 * 
 * Created on December 28, 2011, 10:40 AM
 */

#include <cstdlib>
#include <cstdio>

#include "BufImg.h"

BufImg::BufImg() : buf(NULL), w(0), h(0) {
}


BufImg::~BufImg() {
    delete buf;
}

bool BufImg::isInBounds(int x, int y) {
    return ((x > 0) && (x < w) && (y > 0) && (y < h));
}
    
int BufImg::getWidth() {
    return w;
}

int BufImg::getHeight() {
    return h;
}


int BufImg::ofs(int x, int y) {
    return y*w*4 + x*4;
}

void BufImg::setPixelAt(int byteofs, const IntRGBA & rgba) {
    for(int i = 0; i < 4; ++i)
        buf[byteofs + i] = rgba[i];
}

void BufImg::getPixelAt(int byteofs, IntRGBA & rgba) {
    for(int i = 0; i < 4; ++i)
        rgba[i] = buf[byteofs + i];
}

////

void BufImg::load(const char * fn) {
    FILE * f = fopen(fn, "rb");
    
    fread(&w, sizeof(w), 1, f);
    fread(&h, sizeof(h), 1, f);
    
    //printf("image wh = %i, %i\n", w, h);
    
    delete buf;
    
    buf = new unsigned char[sz()];
    fread(buf, sz(), 1, f);
    
    fclose(f);    
}

void BufImg::save(const char * fn) {
    FILE * f = fopen(fn, "wb");
    
    fwrite(&w, sizeof(w), 1, f);
    fwrite(&h, sizeof(h), 1, f);
        
    fwrite(buf, sz(), 1, f);
    
    fclose(f);
}

int BufImg::sz() {
    return w*h*4;
}