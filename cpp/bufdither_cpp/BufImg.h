/* 
 * File:   BufImg.h
 * Author: yur
 *
 * Created on December 28, 2011, 10:40 AM
 */

#ifndef BUFIMG_H
#define	BUFIMG_H

#include "PixelProvider.h"

class BufImg : public PixelProvider {
public:
    BufImg();    
    virtual ~BufImg();
    
    bool isInBounds(int x, int y);
    
    int getWidth();
    int getHeight();
    /// returns false if x,y is out of bounds
    int ofs(int x, int y);   
    void setPixelAt(int byteofs, const IntRGBA & rgba);
    void getPixelAt(int byteofs, IntRGBA & rgba);
    
    ////
    
    void load(const char * fn);
    void save(const char * fn);
private:
    
    int w,h;
    char * buf;
    
    
    int sz();

};

#endif	/* BUFIMG_H */

