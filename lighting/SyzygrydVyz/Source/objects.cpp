/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#include <cstring>
#include "objects.h"


void polar_camera( float dist, float twist, float elev, float azim )
{
	glTranslatef(0,0,-dist);
	glRotatef(twist,0,0,1);
	glRotatef(elev,1,0,0);
	glRotatef(azim,0,1,0);
}

void background( float* tcolor, float* bcolor )
{
	glPushAttrib(GL_ENABLE_BIT | GL_LIGHTING_BIT | GL_POLYGON_BIT | GL_DEPTH_BUFFER_BIT);
	glDisable(GL_LIGHTING);
	glShadeModel(GL_SMOOTH);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glDepthMask(GL_FALSE);
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
		glLoadIdentity();
		gluOrtho2D(0,1,0,1);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
			glLoadIdentity();
			glBegin(GL_POLYGON);
				glColor3fv(bcolor);
				glVertex2f(0,0);
				glVertex2f(1,0);
				glColor3fv(tcolor);
				glVertex2f(1,1);
				glVertex2f(0,1);
			glEnd();
		glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();

	glPopAttrib();
}


void origin(float* xcolor, float* ycolor, float* zcolor)
{
	glBegin(GL_LINES);
		glColor3fv(xcolor);
		glVertex3f(0,0,0);
		glVertex3f(1,0,0);
		
		glColor3fv(ycolor);
		glVertex3f(0,0,0);
		glVertex3f(0,1,0);

		glColor3fv(zcolor);
		glVertex3f(0,0,0);
		glVertex3f(0,0,1);
	glEnd();
}


void light_origin( int light, float* color, float* pos )
{
	glPushMatrix();
		glTranslatef(pos[0], pos[1], pos[2]);

		glColor3fv( color );
		glutWireSphere(1,4,2);
		glPopMatrix();

	glPopAttrib();
}


void grid( float width, float depth, int wdev, int ddev )
{
	glBegin(GL_LINES);
		// all lines share a Z axis normal
		glNormal3f(0,0,1);

		// draw the width lines (x)
		int n;
		float span = depth/ddev;
		for( n=0; n<ddev+1; n++ )
		{
			glVertex3f(0, n*span, 0);
			glVertex3f(width, n*span, 0);
		}

		// draw the depth lines (y)
		span = width/wdev;
		for( n=0; n<wdev+1; n++ )
		{
			glVertex3f(n*span, 0, 0);
			glVertex3f(n*span, depth, 0);
		}
	glEnd();
}


void draw_string( const char* s )
{
	glPushAttrib( GL_CURRENT_BIT );

	int len = strlen(s);
	for( int i=0; i<len; i++ )
		glutBitmapCharacter(GLUT_BITMAP_9_BY_15, s[i] );

	glPopAttrib();
}