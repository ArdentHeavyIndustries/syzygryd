/*
 *  MyOpenGLComponent.cpp
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 4/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "MyOpenGLComponent.h"

#include <ctype.h>	// for isupper, etc.
#include <math.h>	// for pow, sqrt, etc.
#include <stdio.h>	// for printf
//#include <unistd.h>

#include "utils.h"
#include "objects.h"
#include "syzygryd.h"
#include "sky.h"
#include "glm.h"

#include <GLUT/glut.h>

#ifdef _WIN32
#pragma warning( disable: 4305 )
#endif

float white[] = {1,1,1,1};
float gray[] = {0.5,0.5,0.5,1};
float black[] = {0,0,0,1};
float red[] = {1,0,0,1};
float green[] = {0,1,0,1};
float blue[] = {0,0,1,1};
float cyan[] = {0,1,1,1};
float magenta[] = {1,0,1,1};
float yellow[] = {1,1,0,1};

float warm_gray[] = {0.6,0.6,0.5,1};
float cold_gray[] = {0.5,0.6,0.6,1};
float sky_blue[] = {0.1,0.1,0.2,1};
float cloud_gray[] = {0.0,0.0,0.1,1};
float playa_white[] = {1.0,1.0,0.9,1};

float rain_head[] = {0.8, 0.8, 1, 0.2};
float rain_tail[] = {0.3, 0.4, 0.4, 0};


/////////////////////////////////////////////////////////////////////

// display size
bool fullscreen = false;
int win_pos[2] = {160,120};
int win_size[2] = {640,480};

// camera pos
const float cMinCamDist = 10.0;
const float cMaxCamDist = 10000.0;
const float cCamDist = 1000.0;
const float cCamElev = 6.0;
const float cCamAzim = 0.0;
const float cCamTilt = 0.0;
const float cCamPanX = 0.0;
const float cCamPanY = 0.0;
float cam_dist = cCamDist;
float cam_elev = cCamElev;
float cam_azim = cCamAzim;
float cam_tilt = cCamTilt;
float cam_panx = cCamPanX;
float cam_pany = cCamPanY;

// lighting
float light_pos[] = {-100,-100,300, 1};
float mat_specular[] = {1,1,1,1};
float mat_shininess[] = { 30 };
float mat_ambient[] = {0.05, 0.05, 0.05, 1};
float lmodel_ambient[] = {0.01, 0.01, 0.01, 1};

// used for tracking
bool edit_cam = false;
int mouse_pos[2] = {0,0};
int modifiers = 0;

// environ parameters
bool ortho = false;
bool gridon = false;
bool planeon = true;
bool smooth = true;
bool wire = false;
bool lights = true;
bool cull = true;
bool fps_status = false;

// animation params
bool anim = false;
bool cont = false;
bool half = false;
unsigned int max_fps = 60;
float last_fps = 0.0;

// virtual art
Syzygryd* syzygryd = 0L;
Sky* sky = 0L;
GLUquadric *plane = 0L;

MyOpenGLComponent::MyOpenGLComponent() 
{
	cont = true;
	anim = true;
	
	startTimer (100);
}

MyOpenGLComponent::~MyOpenGLComponent()
{
	anim = false;
	syzygryd->dmx.stopThread (3000);
}

const String& MyOpenGLComponent::getLastData()
{
	return syzygryd->dmx.getLastData();
}

// OpenGLComponent methods
void MyOpenGLComponent::renderOpenGL()
{	

	
	//glViewport(0, 0, w, h);
	set_projection();
	
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	sky->Draw();
	
	// draw the status
	if( fps_status )
	{
		char s[64];
		sprintf( s, "fps: %.1f", last_fps );
		draw_string( s );
	}
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	{
		// camera motion
		glTranslatef(cam_panx, cam_pany, 0);
		polar_camera(cam_dist, cam_tilt, cam_elev, cam_azim);
		gluLookAt(0,-1,0, 0,0,0, 0,0,1);
		
		// main light
		glPushMatrix();
		{
			//			glLoadIdentity();
			//			static float f=0;
			//			f+= 1;
			//			glRotatef(f,0,0,1);
			
			// moon
			glLightfv(GL_LIGHT0, GL_POSITION, light_pos);
			
			
			// lightning
			float lt_pos[] = { syzygryd->size[0]/2,syzygryd->size[1]/2,30,1};
			glLightfv(GL_LIGHT1, GL_POSITION, lt_pos);
		}
		glPopMatrix();
		
		// objects
		syzygryd->Draw();
		
		// surface plane
		if( planeon )
		{			
			glPushAttrib(GL_LIGHTING_BIT);
			
			glDisable(GL_COLOR_MATERIAL);
			glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, black);
			glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, playa_white);
			glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, black);
			glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
			glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0);
			gluDisk(plane, 0, 2000, 36, 1);
			
			glPopAttrib();
		}
		
		// some navigation toys
		if( gridon )
		{
			glPushAttrib( GL_LIGHTING_BIT );
			glDisable(GL_LIGHTING);
			
			glPushMatrix();
			float w=syzygryd->size[0]*2, d=syzygryd->size[1]*2;
			glTranslatef(-w/2, -d/2, 0);
			glColor3fv(gray);
			grid(w, d, w/16, d/16 );
			glPopMatrix();
			
			glPushMatrix();
			glTranslatef(0,0,0.1f);
			origin(red,green,blue);
			glPopMatrix();
			
			//			GLfloat light0_pos[4];
			//			glGetLightfv(GL_LIGHT0, GL_POSITION, light0_pos);
			light_origin(GL_LIGHT0, yellow, light_pos);
			
			glPopAttrib();
		}
	}
	glPopMatrix();
	glFinish();
}

void MyOpenGLComponent::newOpenGLContextCreated()
{
	glClearColor(0,0,0,0.5f);
	glClearDepth(1.0f);
	
	glEnable(GL_DEPTH_TEST);
	
	glShadeModel(smooth ? GL_SMOOTH : GL_FLAT);
	
	glEnable(GL_COLOR_MATERIAL);
	glPolygonMode(GL_FRONT_AND_BACK, wire ? GL_LINE : GL_FILL);
	
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);					// Set Line Antialiasing
	glEnable(GL_BLEND);							// Enable Blending
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
	
	if( cull ) glEnable(GL_CULL_FACE);
	if( lights ) glEnable(GL_LIGHTING);
	
	glEnable(GL_LIGHT0);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);
	glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.01);
	
	plane = gluNewQuadric();
	gluQuadricNormals(plane, GLU_SMOOTH);
	
	// create the landscape
	//syzygryd = new Syzygryd("syzygryd.obj", "syzygryd_lights.obj", "/dev/cu.usbserial-FTSK5W77");
	//	syzygryd = new Syzygryd("syzygryd.obj", "syzygryd_lights.obj", "/dev/cu.usbserial-FTSK5W77");
	
	File workingPath = File::getSpecialLocation(File::currentApplicationFile);
	File model (workingPath.getSiblingFile ("syzygryd_model.obj"));
	File lights (workingPath.getSiblingFile ("syzygryd_lights.obj"));
				
	syzygryd = new Syzygryd(model.getFullPathName().toUTF8(), lights.getFullPathName().toUTF8(), "");
	sky = new Sky(cloud_gray, sky_blue);
}

void MyOpenGLComponent::mouseDrag (const MouseEvent& e)
{
	float delta_x = e.getDistanceFromDragStartX() / 10.0;
	float delta_y = e.getDistanceFromDragStartY() / 10.0;
	
	if (e.mods.isAltDown()) {
		// scale along both axes (+/- dist from last point)
		cam_zoom( sqrt(pow(delta_x,2) + pow(delta_y,2))/2
				 * (delta_x+delta_y<0.0?-1.0:1.0) );
	} else if (e.mods.isShiftDown()) {
		cam_panx += delta_x/4;
		cam_pany -= delta_y/4;
	} else {
		cam_azim += delta_x/2;
		cam_elev += delta_y/2;
	}
}

// Timer methods
void MyOpenGLComponent::timerCallback()
{
	if( anim )
	{
		static float oldt;
		static float fpst;
		static int frames;
		
		// if we're continuing then reset oldt so delta is not huge
		if( cont )
			oldt = timer();
		
		// calc the time delta in seconds since the last frame
		float newt = timer();
		
		// calc the fps
		float fps_delta = newt-fpst;
		if( fps_delta >= 1.0 )
		{
			last_fps = frames/fps_delta;
			fpst = newt;
			frames = 0;
		}
		
		// do the animation
		float delta=(newt-oldt);
		
		// half speed?
		if( half )
			delta /= 8;		// 1/8th for now
		
		// do the animation
		sky->Animate( delta );
		syzygryd->Animate( delta );
		
		// spin around center
		//		cam_azim += 1.0 * delta;
		//		if( cam_azim > 360.0 )
		//			cam_azim -= 360.0;
		
		// update
		repaint();
		oldt = newt;
		frames++;
		
		// repost for next frame
		cont = false;
	}
}

void MyOpenGLComponent::set_projection()
{
	int frame[4];
	glGetIntegerv(GL_VIEWPORT, frame);
	float aspect = float(frame[2])/float(frame[3]);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if( ortho )
	{
		// ortho view scaled by camera distance (zooming)
		float scale = cam_dist;
		float width = scale * 1.0/aspect;
		glOrtho(-scale/2,scale/2,
				-width/2,width/2,
				-10000,10000);
	}
	else
		gluPerspective( 60, aspect, 1, 20000);
	
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}


void MyOpenGLComponent::reset_camera()
{
	cam_dist = cCamDist;
	cam_elev = cCamElev;
	cam_azim = cCamAzim;
	cam_tilt = cCamTilt;
	cam_panx = cCamPanX;
	cam_pany = cCamPanY;
	ortho = false;
	set_projection();
}


void MyOpenGLComponent::cam_zoom( float delta )
{
	if( cam_dist + delta < cMinCamDist )
		cam_dist = cMinCamDist;
	else if( cam_dist + delta > cMaxCamDist )
		cam_dist = cMaxCamDist;
	else
		cam_dist += delta;
	
	if( ortho )
		set_projection();
}
