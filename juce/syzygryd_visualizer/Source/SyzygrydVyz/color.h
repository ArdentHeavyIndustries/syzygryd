/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#ifndef COLOR_H
#define COLOR_H

#include <limits.h>

#define HUE_MAX USHRT_MAX
#define SAT_MAX UCHAR_MAX
#define VAL_MAX UCHAR_MAX
#define RGB_MAX UCHAR_MAX

typedef unsigned char cuint8;
typedef unsigned short cuint16;

typedef struct {
	cuint8 r, g, b;
} rgb_t;

typedef struct {
	cuint16 h;
	cuint8 s, v;
} hsv_t;

void RGBtoHSV( rgb_t rgb, hsv_t *hsv );
void HSVtoRGB( hsv_t hsv, rgb_t *rgb );

void HSVtoRGBW( hsv_t hsv, short *red, short *grn, short *blu, short *wht );
void RGBtoRGBW( rgb_t rgb, short *red, short *grn, short *blu, short *wht );

void MixRGB( rgb_t *out, rgb_t fg, rgb_t bg, cuint8 alpha );

#endif
