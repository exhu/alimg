/* 
 * File:   PixelProvider.h
 * Author: yur
 *
 * Created on December 28, 2011, 10:41 AM
 */

#ifndef PIXELPROVIDER_H
#define	PIXELPROVIDER_H

typedef int IntRGBA[4];

class PixelProvider {
public:
    virtual bool isInBounds(int x, int y) = 0;
    
    virtual int getWidth() = 0;
    virtual int getHeight() = 0;
    /// returns false if x,y is out of bounds
    virtual int ofs(int x, int y) = 0;
    virtual void setPixelAt(int byteofs, IntRGBA rgba) = 0;
    virtual void getPixelAt(int byteofs, IntRGBA rgba) = 0;
};

#endif	/* PIXELPROVIDER_H */

