#include "buf_img.h"

#include <stdlib.h>
#include <stdio.h>

buf_img * buf_img_load(char * fn) {
    buf_img * img = malloc(sizeof(buf_img));
    
    FILE * f = fopen(fn, "rb");
    
    fread(&img->w, sizeof(img->w), 1, f);
    fread(&img->h, sizeof(img->h), 1, f);
    
    //printf("image wh = %i, %i\n", w, h);
    
    int sz = img->w*img->h*4;
    img->buf = malloc(sz);
    fread(img->buf, sz, 1, f);
    
    fclose(f);
    return img;
}


void buf_img_save(buf_img * img, char * fn) {
    FILE * f = fopen(fn, "wb");
    
    fwrite(&img->w, sizeof(img->w), 1, f);
    fwrite(&img->h, sizeof(img->h), 1, f);
        
    int sz = img->w*img->h*4;
    fwrite(img->buf, sz, 1, f);
    
    fclose(f);
}


void buf_img_release(buf_img * b) {
    free(b->buf);
    free(b);
}





/*
int buf_img_get_width(buf_img * img) {
    return img->w;
}


int buf_img_get_height(buf_img * img) {
    return img->h;
}
*/




