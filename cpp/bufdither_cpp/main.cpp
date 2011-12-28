/* 
 * File:   main.cpp
 * Author: yur
 *
 * Created on December 28, 2011, 10:40 AM
 */

#include <cstdlib>
#include <cstdio>

#include "BufImg.h"
#include "PixelDither.h"

using namespace std;


static void reduce(const char * src, const char * dst) {
    BufImg * img = new BufImg();
    img->load(src);

    PixelDither * dither = new PixelDither();
    ColorReducer * reducer = new ColorReducer(ColorReducer::pf4444);

    
    dither->ditherImage(img, reducer);

    img->save(dst);
    //printf("saved.\n");
    
    delete reducer;
    delete dither;
    delete img;
}

/*
 * 
 */
int main(int argc, char** argv) {
    printf("bufdither_cpp in.buf out.buf\n");
        
    
    for(int i = 0; i < 100; ++i)
        reduce(argv[1], argv[2]);

    return 0;
}

