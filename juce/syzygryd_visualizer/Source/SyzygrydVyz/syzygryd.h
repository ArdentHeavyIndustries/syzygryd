/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#include "dmx.h"
#include "glm.h"

struct Syzygryd
{
	DMX dmx;
	
	// map model
	GLMmodel* model;
	GLMmodel* lights;
	float size[3];
	GLuint list;

	Syzygryd( const char* modelPath, const char* lightsPath, const char *devicePath );
	~Syzygryd();

	void Draw();
	void Animate( float tdelta );
};
