/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
*/

#pragma once

void polar_camera( float dist, float twist, float elev, float azim );
void background( float* tcolor, float* bcolor );
void origin(float* xcolor, float* ycolor, float* zcolor);
void light_origin( int light, float* color, float* pos );
void grid( float width, float depth, int wdev, int ddev );

void draw_string( const char* s );
