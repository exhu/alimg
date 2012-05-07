/* 
 * File:   color_reducer.h
 * Author: yur
 *
 * Created on May 7, 2012, 10:52 PM
 */

#ifndef COLOR_REDUCER_H
#define	COLOR_REDUCER_H

#include "buf_img.h"

#ifdef	__cplusplus
extern "C" {
#endif
    
// supports only 4444 format
    
typedef int (*downgrade_comp_func)(int a, int cNum);

typedef struct {
    downgrade_comp_func downgr;
} color_reducer;

void color_reducer_init(color_reducer * r);
void color_reducer_to_closest(const color_reducer * r, const trgba * src, trgba * dest);

#ifdef	__cplusplus
}
#endif

#endif	/* COLOR_REDUCER_H */

