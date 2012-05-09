#include "pixel_dither.h"

inline static int clamp(int v) {
    if (v < 0)
        return 0;

    if (v > 255)
        return 255;

    return v;
}


inline static void calc_diff(trgba * out, const trgba * a, const trgba * b) {
    for(int n = 0; n < 4; ++n) {
        out->rgba[n] = a->rgba[n] - b->rgba[n];
    }
}

inline static void apply_error(trgba * rgba, const trgba * diff, int coef) {
    for (int i = 0; i < 4; ++i) {
        rgba->rgba[i] = clamp(rgba->rgba[i] + diff->rgba[i] * coef / 16);
    }
}


inline static void correct_pixel(buf_img * img, int x, int y, int coef, const trgba * diff) {
    if (buf_img_is_in_bounds(img, x, y)) {
        const int ofs = buf_img_ofs(img, x, y);
        trgba tmp;
        buf_img_get_pixel(img, ofs, &tmp);
        apply_error(&tmp, diff, coef);
        buf_img_set_pixel(img, ofs, &tmp);
    }
}

void pixel_dither_do(buf_img * img, color_reducer * reducer) {
    const int w = img->w;        
    const int h = img->h;
    //const int last_row = h-1;
    //const int last_col = w-1;
    trgba rgba;
    trgba rgba_reduced;
    trgba rgba_diff;
    
    
    for(int y = 0; y < h; ++y)
        for(int x = 0; x < w; ++x) {
            const int ofs = buf_img_ofs(img, x, y);
            buf_img_get_pixel(img, ofs, &rgba);
            color_reducer_to_closest(reducer, &rgba, &rgba_reduced);
            buf_img_set_pixel(img, ofs, &rgba_reduced);

            calc_diff(&rgba_diff, &rgba, &rgba_reduced);

            //////////////////////////
            // order, apply error to original pixels
            // (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16

#if 1
            correct_pixel(img, x-1, y+1, 3, &rgba_diff);
            correct_pixel(img, x, y+1, 5, &rgba_diff);
            correct_pixel(img, x+1, y+1, 1, &rgba_diff);                
            correct_pixel(img, x+1, y, 7, &rgba_diff);
#else            
            const bool not_last_row = (y < last_row);
            const bool not_last_col = (x < last_col);
            if (not_last_row) {
                if (x > 0)
                    correct_pixel(img, x-1, y+1, 3, &rgba_diff);
                
                correct_pixel(img, x, y+1, 5, &rgba_diff);

                if (not_last_col)
                    correct_pixel(img, x+1, y+1, 1, &rgba_diff);
            }

            if (not_last_col)
               correct_pixel(img, x+1, y, 7, &rgba_diff);
#endif
        }
}