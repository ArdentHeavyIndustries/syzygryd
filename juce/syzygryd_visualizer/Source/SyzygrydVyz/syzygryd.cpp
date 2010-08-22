/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

//#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "syzygryd.h"
#include "objects.h"
#include "utils.h"

//#include <CoreFoundation/CoreFoundation.h>

#pragma warning(disable:4305)

#define bzero(b,len) (memset((b), '\0', (len)), (void) 0)

Syzygryd::Syzygryd(const char* modelPath, 
				   const char* lightsPath,
				   const char* flamesPath,
				   const char* tornadoPath,
				   const char *devicePath)
: dmx(), model(0L), lights(0L), flames(0L), tornado(0L), list(-1)
{
	bzero(&size, sizeof(size));
	
	model = glmReadOBJ((char*)modelPath);	// will exit on failure
	glmDimensions( model, size );
//	glmReverseWinding(model);
//	glmFacetNormals(model);
//	glmVertexNormals(model, 45.0);
	list = glmList(model, GLM_SMOOTH | GLM_MATERIAL);
	
	
	{
		model->nummaterials = 1;
		size_t size = sizeof(GLMmaterial) * model->nummaterials;
		model->materials = (GLMmaterial*)malloc(size);
		bzero(model->materials, size);
		
		// set the default material
		GLMmaterial *mat = &(model->materials[0]);
		GLfloat color[4] = {1,1,1,1};
		GLfloat ambient[4] = {0.1,0.1,0.1,1};
		memcpy(mat->diffuse, color, sizeof(color));
		memcpy(mat->ambient, ambient, sizeof(ambient));
		//memcpy(mat->specular, color, sizeof(color));
		//memcpy(mat->emmissive, color, sizeof(color));
		mat->shininess = 100;
	}
	
	
	//glmFacetNormals( model );		// used by collision detection
	//glmReverseWinding(model);
	
	
	
	// init cube materials
	lights = glmReadOBJ((char*)lightsPath);	// will exit on failure
	lights->nummaterials = 108 + 1;
	size_t materialSize = sizeof(GLMmaterial) * lights->nummaterials;
	lights->materials = (GLMmaterial*)malloc(materialSize);
	bzero(lights->materials, materialSize);
	
	// set the default material
	GLMmaterial *mat = &(lights->materials[0]);
	GLfloat color[4] = {1,1,1,1};
	GLfloat ambient[4] = {0.1,0.1,0.1,1};
	memcpy(mat->diffuse, color, sizeof(color));
	memcpy(mat->ambient, ambient, sizeof(ambient));
	//memcpy(mat->specular, color, sizeof(color));
	//memcpy(mat->emmissive, color, sizeof(color));
	mat->shininess = 100;
	
	// walk the model looking for groups labeled "cubeXXX" and assign them a material number
	int i = 0;
	GLMgroup* group = lights->groups;
	while(group)
	{
		int cube;
		if( sscanf(group->name, "light%i", &cube) == 1 )
		{
			printf("cube # %i\n", cube);
			group->material = cube; 
		}
		else {
			printf("object: %s\n", group->name);
		}

		
		i++;
		group = group->next;
	};
	
	printf("%s dimensions: %f %f %f\n", modelPath, size[0], size[1], size[2] );
	
	// ------------------------------------------------------------------------
	// Load the flames
	// ------------------------------------------------------------------------
	
	// init flames materials
	flames = glmReadOBJ((char*)flamesPath);	// will exit on failure
	flames->nummaterials = 24;
	size_t flameMaterialSize = sizeof(GLMmaterial) * flames->nummaterials;
	flames->materials = (GLMmaterial*)malloc(flameMaterialSize);
	bzero(flames->materials, flameMaterialSize);
	
	// walk the model looking for groups labeled "flameXXX" and assign them a material number
	i = 0;
	GLMgroup* flameGroup = flames->groups;
	while(flameGroup)
	{
		int flame;
		if( sscanf(flameGroup->name, "flame%i", &flame) == 1 )
		{
			printf("flame # %i\n", flame);
			flameGroup->material = flame; 

			GLMmaterial *flameMat = &(flames->materials[i]);

			GLfloat flameColor[4] = {0.8,0.3,0.3,1};
			GLfloat flameAmbient[4] = {0.1,0.1,0.1,1};
			memcpy(flameMat->diffuse, flameColor, sizeof(flameColor));
			memcpy(flameMat->ambient, flameAmbient, sizeof(flameAmbient));
			memcpy(flameMat->specular, flameColor, sizeof(flameColor));
			memcpy(flameMat->emmissive, flameColor, sizeof(flameColor));
			flameMat->shininess = 0.0;
		} else {
			printf("object: %s\n", flameGroup->name);
		}
		
		i++;
		flameGroup = flameGroup->next;
	};
	
	// ------------------------------------------------------------------------
	// Load the tornado
	// ------------------------------------------------------------------------
	
	// init tornado materials
	tornado = glmReadOBJ((char*)tornadoPath);	// will exit on failure
	tornado->nummaterials = 4 + 1;
	size_t tornadoMaterialSize = sizeof(GLMmaterial) * tornado->nummaterials;
	tornado->materials = (GLMmaterial*)malloc(tornadoMaterialSize);
	bzero(tornado->materials, tornadoMaterialSize);
	
	{
		GLMmaterial *mat = &(tornado->materials[0]);
		
		GLfloat color[4] = {0.9,0.1,0.1,1};
		GLfloat ambient[4] = {0.1,0.1,0.1,1};
		memcpy(mat->diffuse, color, sizeof(color));
		memcpy(mat->ambient, ambient, sizeof(ambient));
		memcpy(mat->specular, color, sizeof(color));
		memcpy(mat->emmissive, color, sizeof(color));
		mat->shininess = 0.0;
	}
	
	// ------------------------------------------------------------------------
	// Start the DMX reader
	// ------------------------------------------------------------------------
	dmx.Start(devicePath);
}


Syzygryd::~Syzygryd()
{
	glmDelete(model);
	glmDelete(lights);
	glmDelete(flames);
	model = 0L;
	lights = 0L;
	flames = 0L;
	// delete list
}


void Syzygryd::Draw()
{
	glPushAttrib(GL_CURRENT_BIT|GL_LIGHTING_BIT|GL_POLYGON_BIT);
	glmDraw(model, GLM_SMOOTH | GLM_MATERIAL);

	glPushMatrix();
	glScalef(100.0, 100.0, 100.0);
	glmDraw(flames, GLM_SMOOTH | GLM_MATERIAL);
	glPopMatrix();		
	
/*
	glPushMatrix();
	glScalef(100.0, 100.0, 100.0);
	glmDraw(tornado, GLM_SMOOTH | GLM_MATERIAL);
	glPopMatrix();			
*/
 
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glLineWidth(2);
	glPushMatrix();
	glmDraw(lights, GLM_SMOOTH | GLM_MATERIAL);
	glPopMatrix();

	glPopAttrib();
}


void Syzygryd::Animate( float tdelta )
{
	// canned vis
	if( !dmx.IsRunning() )
		dmx.Animate(tdelta);
	
	
	//if( pthread_mutex_lock(&(dmx._mutex)) == 0 )
	{
		ScopedLock lock (dmx.cs);
		// walk the materials and code in the colors from the DMX world, material[0] is the frame, it is black
		for( unsigned int i=1, d=1; i<lights->nummaterials; i++, d+=3 )
		{
			GLMmaterial *mat = &(lights->materials[i]);
			GLfloat color[4] = {1,1,1,1};

			color[0] = (GLfloat)(dmx.world2[d  ])/255.0;
			color[1] = (GLfloat)(dmx.world2[d+1])/255.0;
			color[2] = (GLfloat)(dmx.world2[d+2])/255.0;
			
			memcpy(mat->diffuse, color, sizeof(color));
			memcpy(mat->ambient, color, sizeof(color));
			memcpy(mat->specular, color, sizeof(color));
			memcpy(mat->emmissive, color, sizeof(color));
			mat->shininess = 0.0;
		}

		// control cubes not implemented
		
		int numFlames = 24;
		for (int i = 0; i < numFlames; i++) 
		{
			GLMmaterial *mat = &(flames->materials[i+1]);
			GLfloat color[4] = {0,0,0,0};
			
			//int dmxIndex = lights->nummaterials + 9 + i - 2;
			int numLights = 36;
			int numControlCubes = 9;
			int dmxIndex = (numLights*3*3)+numControlCubes; // won't change
			if (dmx.world2[dmxIndex+i] > 1) {
				color[0] = 1.0;
				color[1] = 0.3;
				color[2] = 0.3;
				color[3] = 1.0;
			}
			
			memcpy(mat->diffuse, color, sizeof(color));
			memcpy(mat->ambient, color, sizeof(color));
			memcpy(mat->specular, color, sizeof(color));
			memcpy(mat->emmissive, color, sizeof(color));
			mat->shininess = 0.0;			
		}
	//pthread_mutex_unlock(&(dmx._mutex));
	}
}
