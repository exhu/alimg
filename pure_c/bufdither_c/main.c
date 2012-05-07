/* 
 * File:   main.c
 * Author: yur
 *
 * Created on May 6, 2012, 10:44 PM
 */

#include <stdio.h>
#include <stdlib.h>

#include "pixel_dither.h"
/*
 * 
 */
int main(int argc, char** argv) {

    buf_img * img = buf_img_load(argv[1]);
    color_reducer reducer;
    color_reducer_init(&reducer);
    
    for(int i = 0; i < 100; ++i) {
        pixel_dither_do(img, &reducer);
    }
    
    buf_img_save(img, argv[2]);
    buf_img_release(img);
    
    return (EXIT_SUCCESS);
}

