/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#include "color.h"
#include <math.h>

cuint8 min3( cuint8 a, cuint8 b, cuint8 c )
{ return (a<b && a<c) ? a : (b<c ? b : c); }

cuint8 max3( cuint8 a, cuint8 b, cuint8 c )
{ return (a>b && a>c) ? a : (b>c ? b : c); }


void RGBtoHSV( rgb_t rgb, hsv_t *hsv )
{
	float minVal = min3(rgb.r, rgb.g, rgb.b)/(float)RGB_MAX;
	float h, s, v = max3(rgb.r, rgb.g, rgb.b)/(float)RGB_MAX;
	float delta = v - minVal;
	
	// saturation
	if( v==0 )
		s=0;
	else
		s=delta/v;
	
	// hue
	if( s==0 )
		h=0;
	
	else
	{
		float r=rgb.r/(float)RGB_MAX;
		float g=rgb.g/(float)RGB_MAX;
		float b=rgb.b/(float)RGB_MAX;
		
		if( r==v )
			h=60*(g-b)/delta;
		else
		{
			if( g==v )
				h=120+60*(b-r)/delta;
			else
				h=240+60*(r-g)/delta;
		}
		
		// unroll
		if( h<0 ) h=h+360;
	}
	
	hsv->h = (cuint16)(h/360 * HUE_MAX);
	hsv->s = (cuint8)(s * SAT_MAX);
	hsv->v = (cuint8)(v * VAL_MAX);
}

void HSVtoRGB( hsv_t hsv, rgb_t *rgb )
{
	short red, grn, blu, wht;
	HSVtoRGBW(hsv, &red, &grn, &blu, &wht);
	rgb->r = red;
	rgb->g = grn;
	rgb->b = blu;
}


void HSVtoRGBW( hsv_t hsv, short *red, short *grn, short *blu, short *wht )
{
	if( hsv.s == 0 )
	{
		*red = 0;
		*grn = 0;
		*blu = 0;
		*wht = hsv.v;
		return;
	}
	
	float h = hsv.h/(float)HUE_MAX * 360.0;
	float s = hsv.s/(float)VAL_MAX;
	float v = hsv.v/(float)VAL_MAX;
	
	h = h/60;                        // sector 0 to 5
	int i = floor(h);
	float f = h - i;                      // factorial part of h
	float p = v * ( 1 - s );
	float q = v * ( 1 - s * f );
	float t = v * ( 1 - s * ( 1 - f ) );
	
	float r, g, b;
	switch( i )
	{
		case 0:  r=v; g=t; b=p; break;
		case 1:  r=q; g=v; b=p; break;
		case 2:  r=p; g=v; b=t; break;
		case 3:  r=p; g=q; b=v; break;
		case 4:  r=t; g=p; b=v; break;
		default:
			r=v; g=p; b=q; break;
	}
	
	s=(1-s);
	r-=s;
	g-=s;
	b-=s;
	
	*red = r * RGB_MAX;
	*grn = g * RGB_MAX;
	*blu = b * RGB_MAX;
	*wht = (s*v) * RGB_MAX;
}


void RGBtoRGBW( rgb_t rgb, short *red, short *grn, short *blu, short *wht )
{
	// FIXME
	hsv_t hsv;
	RGBtoHSV(rgb, &hsv);
	HSVtoRGBW(hsv, red, grn, blu, wht);
}


void MixRGB( rgb_t *out, rgb_t fg, rgb_t bg, cuint8 alpha )
{
	cuint8 a1 = RGB_MAX-alpha;
	out->r = ((short)fg.r*alpha + (short)bg.r*a1)/RGB_MAX;
	out->g = ((short)fg.g*alpha + (short)bg.g*a1)/RGB_MAX;
	out->b = ((short)fg.b*alpha + (short)bg.b*a1)/RGB_MAX;
}
