/* 
 * File:   buf_img.h
 * Author: yur
 *
 * Created on May 6, 2012, 10:45 PM
 */

#ifndef BUF_IMG_H
#define	BUF_IMG_H

#include <stdbool.h>

#ifdef	__cplusplus
extern "C" {
#endif

    typedef union {
       int rgba[4];
       int r;
       int g;
       int b;
       int a;
    } trgba;
    
    typedef struct {
        unsigned char * buf;
        int w,h;
    } buf_img;

    buf_img * buf_img_load(char * fn);
    void buf_img_save(buf_img * img, char * fn);
    void buf_img_release(buf_img * b);

    //int buf_img_ofs(buf_img * img, int x, int y);
    //bool buf_img_is_in_bounds(buf_img * img, int x, int y);
    
    inline int buf_img_ofs(buf_img * img, int x, int y) {
        return img->w*y*4 + x*4;
    }


    inline bool buf_img_is_in_bounds(buf_img * img, int x, int y) {
        return ((x > 0) && (x < img->w) && (y > 0) && (y < img->h));
    }
    
    //int buf_img_get_width(buf_img * img);
    //int buf_img_get_height(buf_img * img);
    
    //void buf_img_set_pixel(buf_img * img, int ofs, const trgba * v);
    //void buf_img_get_pixel(buf_img * img, int ofs, trgba * out_v);
    
    inline void buf_img_set_pixel(buf_img * img, int ofs, const trgba * v) {
        for(int i = 0; i < 4; ++i)
            img->buf[ofs + i] = v->rgba[i];
    }


    inline void buf_img_get_pixel(buf_img * img, int ofs, trgba * out_v) {
        for(int i = 0; i < 4; ++i)
            out_v->rgba[i] = img->buf[ofs + i];
    }
    
#ifdef	__cplusplus
}
#endif

#endif	/* BUF_IMG_H */

