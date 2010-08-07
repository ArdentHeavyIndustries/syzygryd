/*
 *  Lighting.h
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 8/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef Lighting_H
#define Lighting_H

#include "JuceHeader.h"

class Light;

class Lighting : public Thread
{
public:
	Lighting();
	~Lighting();
	
	// Thread methods
	virtual void run();

private:
	void send();
	
	OwnedArray<Light> lights;	
	int motionIndex;
	
	StreamingSocket socket;
};

#endif
