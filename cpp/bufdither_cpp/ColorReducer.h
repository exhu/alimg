/* 
 * File:   ColorReducer.h
 * Author: yur
 *
 * Created on December 28, 2011, 10:59 AM
 */

#ifndef COLORREDUCER_H
#define	COLORREDUCER_H

#include "PixelProvider.h"

class ColorReducer {
public:
    enum PixelFormat {
        pf4444,
        pf565,
        pf5551
    };
    
    
    ColorReducer(PixelFormat targetPf);
    virtual ~ColorReducer();
    
    void reduceToClosest(const IntRGBA & rgba, IntRGBA & destRGBA);
    
private:
    typedef int (*DowngradeComponentFunc)(int a, int cNum);
    
    DowngradeComponentFunc downgr;
    
    static int downgrade(int a, int targetBitCount);
    
    
    static int downgrade4444(int a, int cNum);
    static int downgrade565(int a, int cNum);
    static int downgrade5551(int a, int cNum);

};

#endif	/* COLORREDUCER_H */

