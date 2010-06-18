/*
*  Created by Michael Estee on 4/5/10.
*  Copyright 2010 Mike Estee. All rights reserved.
*/

#include <ctype.h>	// for isupper, etc.
#include <math.h>	// for pow, sqrt, etc.
#include <stdio.h>	// for printf
#include <unistd.h>

#include "utils.h"
#include "objects.h"
#include "syzygryd.h"
#include "sky.h"
#include "glm.h"

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

/////////////////////////////////////////////////////////////////////
void display();
void animate( int );

/////////////////////////////////////////////////////////////////////

void animate( int )
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
		glutPostRedisplay();
		oldt = newt;
		frames++;
		
		// repost for next frame
		cont = false;
		glutTimerFunc(1000/max_fps, animate, 0);
	}
}


void start()
{
	cont = true;
	anim = true;
	glutTimerFunc(1000/max_fps, animate, 0);		// 60 fps
}

void stop()
{
	// wil exit on next frame
	anim = false;
}


void display()
{
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
	glutSwapBuffers();
}


void set_projection()
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


void reset_camera()
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


void cam_zoom( float delta )
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


void reshape(int w, int h)
{
	glViewport(0, 0, w, h);
	set_projection();
}


void mouse(int button, int state, int x, int y)
{
	modifiers = glutGetModifiers();

	switch(button)
	{
	// right button zooms
	case GLUT_RIGHT_BUTTON:
	case GLUT_MIDDLE_BUTTON:
		modifiers = button==GLUT_RIGHT_BUTTON ?
			GLUT_ACTIVE_CTRL : GLUT_ACTIVE_SHIFT;
		//fall through

	case GLUT_LEFT_BUTTON:
		mouse_pos[0] = x;
		mouse_pos[1] = y;
		edit_cam = (state == GLUT_DOWN);
		break;

	default:
		break;
	}
}


void motion( int x, int y )
{
	// only handle elev and azimuth
	if( edit_cam )
	{
		float delta_x = (x - mouse_pos[0]) / 2.0;
		float delta_y = (y - mouse_pos[1]) / 2.0;

		switch( modifiers )
		{
		// zoom
		case GLUT_ACTIVE_CTRL:
			// scale along both axes (+/- dist from last point)
			cam_zoom( sqrt(pow(delta_x,2) + pow(delta_y,2))/2
				* (delta_x+delta_y<0.0?-1.0:1.0) );
			break;

		// pan
		case GLUT_ACTIVE_SHIFT:
			cam_panx += delta_x/4;
			cam_pany -= delta_y/4;
			break;

		// rotate
		default:
			cam_azim += delta_x/2;
			cam_elev += delta_y/2;
			break;
		}

		mouse_pos[0] = x;
		mouse_pos[1] = y;

		glutPostRedisplay();
	}
}


void idle()
{
}


void set_fullscreen()
{
	if( fullscreen )
	{
		// << if the space bar is held down the
		// window can get stuck in fullscreen mode >>
		win_pos[0] = glutGet(GLUT_WINDOW_X);
		win_pos[1] = glutGet(GLUT_WINDOW_Y);
		win_size[0] = glutGet(GLUT_WINDOW_WIDTH);
		win_size[1] = glutGet(GLUT_WINDOW_HEIGHT);
		glutFullScreen();
	}
	else
	{
		glutPositionWindow( win_pos[0], win_pos[1] );
		glutReshapeWindow( win_size[0], win_size[1] );
	}
}


void print_help()
{
	printf(
	"keyboard commands:\n"
	"------------------------\n"
	"F1   - start the demo\n"
	"F2   - set camera to starting position\n"
	"a    - animation toggle\n"
	"b    - backface removal (culling)\n"
	"c    - reset camera\n"
	"f    - fps status toggle\n"
	"g    - grid visiblity toggle\n"
    "p    - plane visiblity toggle\n"
	"h    - half speed animation toggle\n"
	"l    - light toggle\n"
	"o    - ortho/perspective toggle\n"
	"s    - smooth/flat toggle\n"
	"w    - wireframe/filled toggle\n"
	"tab  - report camera position\n"
	"spc  - fullscrean toggle\n"
	"esc  - cancel\n"
	"q    - exit\n"
	"\n"
	"mouse commands:\n"
	"------------------------\n"
	"left       - rotate camera\n"
	"left-ctl   - zoom camera\n"
	"left-shift - pan camera\n"
	"right      - zoom camera\n"
	"middle     - pan camera\n"
	"\n");
}


void keyboard( unsigned char key, int x, int y )
{
	if( isupper(key) )
		key = tolower(key);

	switch( key )
	{
	case 'a':
		if( anim )
			stop();
		else
			start();
		break;

	case 'c': reset_camera(); break;
	case 'f': fps_status = !fps_status; break;
	case 'g': gridon = !gridon; break;
	case 'p': planeon = !planeon; break;
	case 'h': half = !half; break;
	
	case 'l':
		lights = !lights;
		if( lights )
			glEnable(GL_LIGHTING);
		else
			glDisable(GL_LIGHTING);
		break;

	case 'b':
		cull = !cull;
		if( cull )
			glEnable(GL_CULL_FACE);
		else
			glDisable(GL_CULL_FACE);
		break;

	case 'o':
		ortho = !ortho;
		set_projection();
		break;

	case 's':
		smooth = !smooth;
		glShadeModel(smooth ? GL_SMOOTH : GL_FLAT);
		break;

	case 'w':
		wire = !wire;
		glPolygonMode(GL_FRONT_AND_BACK, wire ? GL_LINE : GL_FILL);
		break;

	case ' ':
		fullscreen = !fullscreen;
		set_fullscreen();
		break;

	case '\t':
		printf("\ncamera:\n"
				"-------------------\n"
				"%3.3f elev\n"
				"%3.3f azim\n"
				"%3.3f dist\n"
				"%3.3f x\n"
				"%3.3f y\n",
				cam_elev,
				cam_azim,
				cam_dist,
				cam_panx,
				cam_pany );
		break;

	case 'q': exit(0); break;
	default:
		print_help();
		break;
	}

	// refresh after a command
	glutPostRedisplay();
}


void special( int key, int x, int y )
{
	switch( key )
	{
	// camera controls
	case GLUT_KEY_LEFT:			cam_azim -= 5.0; break;
	case GLUT_KEY_RIGHT:		cam_azim += 5.0; break;
	case GLUT_KEY_UP:			cam_elev += 5.0; break;
	case GLUT_KEY_DOWN:			cam_elev -= 5.0; break;
	case GLUT_KEY_PAGE_UP:		cam_zoom(-5.0); break;
	case GLUT_KEY_PAGE_DOWN:	cam_zoom( 5.0); break;
	
	case GLUT_KEY_F1:
		ortho = false;
		gridon = false;
		cam_elev = 6;		// 6' tall
		cam_azim = 0;
		cam_dist = 550;
		cam_panx = 0;
		cam_pany = 15;
		set_projection();
		start();
		break;

	case GLUT_KEY_F2:
		ortho = true;
		cam_elev = 25;		// 6' tall
		cam_azim = 40;
		cam_dist = 950;
		cam_panx = 0;
		cam_pany = -44;
		set_projection();
		break;

	default:
		print_help();
		break;
	}

	// refresh after a command
	glutPostRedisplay();
}


void init()
{
	glClearColor(0,0,0,0.5f);
	glClearDepth(1.0f);
	
	glEnable(GL_DEPTH_TEST);

	glShadeModel(smooth ? GL_SMOOTH : GL_FLAT);
	
	glEnable(GL_COLOR_MATERIAL);
	glPolygonMode(GL_FRONT_AND_BACK, wire ? GL_LINE : GL_FILL);

	
	//glShadeModel(GL_SMOOTH);						// Enable Smooth Shading
	//glClearColor(0.0f, 0.0f, 0.0f, 0.5f);					// Black Background
	//glClearDepth(1.0f);
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
	syzygryd = new Syzygryd("syzygryd.obj", "syzygryd_lights.obj", "/dev/cu.usbserial-00002006");
//	syzygryd = new Syzygryd("syzygryd.obj", "syzygryd_lights.obj", "/dev/cu.usbserial-FTSK5W77");
	sky = new Sky(cloud_gray, sky_blue);
	
	// start out running
	start();
}


void print_credits()
{   
	printf(
		"SyzygrydVyz\n"
		"===================================\n"
		"Copyright 1999-2010 Michael Stochosky / Michael Estee\n"
		"All rights reserved.\n"
		"\n"
		"(Press F1 for a demo, or ? for help.)\n"
		"\n"
		);
}


int main( int argc, char** argv )
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH | GLUT_MULTISAMPLE);
	glutInitWindowSize(win_size[0], win_size[1]);
	glutInitWindowPosition(win_pos[0], win_pos[1]);
	glutCreateWindow("Rain");
	
	init();
	
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	glutKeyboardFunc(keyboard);
	glutSpecialFunc(special);
	glutMouseFunc(mouse);
	glutMotionFunc(motion);
	glutIdleFunc(idle);

	print_credits();

	glutMainLoop();
	return 0;
}