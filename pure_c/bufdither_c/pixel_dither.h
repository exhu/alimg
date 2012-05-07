/* 
 * File:   pixel_dither.h
 * Author: yur
 *
 * Created on May 7, 2012, 11:11 PM
 */

#ifndef PIXEL_DITHER_H
#define	PIXEL_DITHER_H

#include "buf_img.h"
#include "color_reducer.h"

#ifdef	__cplusplus
extern "C" {
#endif

    void pixel_dither_do(buf_img * img, color_reducer * reducer);



#ifdef	__cplusplus
}
#endif

#endif	/* PIXEL_DITHER_H */

