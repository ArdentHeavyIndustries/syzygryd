/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
*/

#include "objects.h"
#include "utils.h"
#include "sky.h"

#include <GLUT/glut.h>

#pragma warning(disable:4305)

#define LIGHTNING 0

Sky::Sky( float* tc, float* bc )
: timer(0), flash(0), duration(0.25), delay(randf(2,5)),
light(GL_LIGHT1), top_color(tc), bot_color(bc)
{
	glDisable(light);

	float Kd[] = {0,0,0,1};
	glLightfv(light, GL_DIFFUSE, Kd);
	glLightf(light, GL_LINEAR_ATTENUATION, 0.01);
    glLightf(light, GL_CONSTANT_ATTENUATION, 1);
    glLightf(light, GL_LINEAR_ATTENUATION, 0.01);
}


Sky::~Sky()
{}


void Sky::Draw()
{
#if LIGHTNING
	if( flash > 0 )
	{
		// scale the ambient as a function of time
		float a = flash/duration;
		float a2 = a * 2;
		float Ka[] = {a2,a2,a2,1};
		glLightfv(light, GL_AMBIENT, Ka);
		glEnable(light);

		// fade the white into the original color
		float white[] = {1,1,1,1};
		float a1 = 1 - a;
		white[0] = ((white[0]*a)+(top_color[0]*a1));
		white[1] = ((white[1]*a)+(top_color[1]*a1));
		white[2] = ((white[2]*a)+(top_color[2]*a1));

		background(white, bot_color);
	}
	else
#endif
	{
		background(top_color, bot_color);
		glDisable(light);
	}
}


void Sky::Animate( float tdelta )
{
	if( flash > 0.0 )
	{
		// decay from light
		flash -= tdelta;

		// reset?
		if( flashes && (flash/duration < randf(0,0.3)) )
		{
			flash = duration;
			flashes--;
		}
	}
	else
	{
		timer += tdelta;

		// start the lightning flash
		if( timer > delay )
		{
			flash = duration;
			timer = 0;
			flashes = randi(1, 3)-1;	// how many flashes?
			delay = randf(5,15);
		}
	}
}
