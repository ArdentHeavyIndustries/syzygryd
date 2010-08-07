/*
 *  Light.h
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 8/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef Light_H
#define Light_H

#include "JuceHeader.h"

class Light
{
public:
	Light (const Colour& color_);
	~Light();
	
	const Colour& getColor();
	void setColor (const Colour& color_);

private:
	Colour color;
};

#endif
