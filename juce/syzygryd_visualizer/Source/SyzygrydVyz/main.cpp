/*
*  Created by Michael Estee on 4/5/10.
*  Copyright 2010 Mike Estee. All rights reserved.
*/


/////////////////////////////////////////////////////////////////////
void display();
void animate( int );

/////////////////////////////////////////////////////////////////////

void animate( int )
{

}


void start()
{

	glutTimerFunc(1000/max_fps, animate, 0);		// 60 fps
}

void stop()
{
	// wil exit on next frame
}


void display()
{

}





void reshape(int w, int h)
{
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
