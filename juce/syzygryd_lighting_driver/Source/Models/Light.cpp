/*
 *  Light.cpp
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 8/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Light.h"


Light::Light (const Colour& color_) :
color (color_)
{
}

Light::~Light()
{
}

const Colour& Light::getColor()
{
	return color;
}

void Light::setColor (const Colour& color_)
{
	color = color_;
}




