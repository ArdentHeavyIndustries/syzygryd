/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
*/


#include "utils.h"

// return a random number between min & max
float randf( float min, float max )
{
	float r = float(rand());
	return r/float(RAND_MAX) * (max-min) + min;
}


int randi( int min, int max )
{
	float n = float(rand())/float(RAND_MAX) * float(max-min);

	// round
	if( n-floor(n) > 0.5 )
		n = ceilf(n);
	else
		n = floorf(n);

	return int(n + min);
}


float timer()
{
	return float(glutGet(GLUT_ELAPSED_TIME)) / 1000.0;
}