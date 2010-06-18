/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "syzygryd.h"
#include "objects.h"
#include "utils.h"

#include <CoreFoundation/CoreFoundation.h>

#pragma warning(disable:4305)

Syzygryd::Syzygryd( const char* modelPath, const char* lightsPath, const char *devicePath )
: dmx(), model(0L), lights(0L), list(-1)
{
	bzero(&size, sizeof(size));
	
#ifdef GLUT_MACOSX_IMPLEMENTATION
    CFBundleRef bundle = CFBundleGetMainBundle();
    CFURLRef ref = CFBundleCopySupportFilesDirectoryURL(bundle);
    if( ref )
    {
        CFStringRef pathStr = CFURLCopyPath(ref);
        if( pathStr )
        {
            char path[256];
            if( CFStringGetCString(pathStr, path, sizeof(path), kCFStringEncodingUTF8) )
                chdir(path);
            
            CFRelease(pathStr);
        }
        CFRelease(ref);
    }
#endif
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
	
	dmx.Start(devicePath);
}


Syzygryd::~Syzygryd()
{
	glmDelete(model);
	glmDelete(lights);
	model = 0L;
	lights = 0L;
	// delete list
}


void Syzygryd::Draw()
{
	glPushAttrib(GL_CURRENT_BIT|GL_LIGHTING_BIT|GL_POLYGON_BIT);
	glmDraw(model, GLM_SMOOTH | GLM_MATERIAL);
	
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
	
	if( pthread_mutex_lock(&(dmx._mutex)) == 0 )
	{
		// walk the materials and code in the colors from the DMX world, material[0] is the frame, it is black
		for( unsigned int i=1, d=1; i<lights->nummaterials; i++, d+=3 )
		{
			GLMmaterial *mat = &(lights->materials[i]);
			GLfloat color[4] = {1,1,1,1};
			color[0] = (GLfloat)(dmx.world[d  ])/255.0;
			color[1] = (GLfloat)(dmx.world[d+1])/255.0;
			color[2] = (GLfloat)(dmx.world[d+2])/255.0;
			
			memcpy(mat->diffuse, color, sizeof(color));
			memcpy(mat->ambient, color, sizeof(color));
			memcpy(mat->specular, color, sizeof(color));
			memcpy(mat->emmissive, color, sizeof(color));
			mat->shininess = 0.0;
		}
		pthread_mutex_unlock(&(dmx._mutex));
	}
}