/*
 *  StarField.cpp
 *  starfield2
 *
 *  Created by Matt Sonic on 7/23/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "StarField.h"

#include <math.h>
#include <stdlib.h>

StarField::StarField (int rows, int cols) :
width (cols),
height (rows),
ovrlcnst (0.45L),
starnumber (35),
xpixoffrt (380L),
ypixofftop (140L), 
xpixofflft (250L),
ypixoffbot (320L),
xpixbrtrt (480L), 
ypixbrttop (95L), 
xpixbrtlft (180L),
ypixbrtbot (350L),
centerx (320L)
{
	for (int i = 0; i < starnumber; i++) {
		Star* star = new Star();
		
		stars.add (star);
		
	}
	
	double startxypos[2] = { width / 2, height / 2 };
	locstar *star; /* set up star struct */
	
	for (int i = 0; i <= starnumber-1; i++) /* loop through starnumber stars */
	{
		newstar (i, star, startxypos, true);
	}	
}

StarField::~StarField()
{
}

void StarField::update()
{
	updateForeground();
}

bool StarField::getActiveAt (int row, int col)
{
	for (int i = 0; i < starnumber; i++) {
		if (((int)stars[i]->xpos == col) &&
			((int)stars[i]->ypos == row)) {
			return true;
		}
	}
	return false;
}

int StarField::getRows()
{
	return height;
}

int StarField::getCols()
{
	return width;
}

void StarField::updateBackground()
{
	int x, y; /* local x,y position of each star */
	unsigned i, colorch = 12; /* color to start with in background*/
	srand (2); /* seed the random number generator*/
	
	for (i = 0; i <= 100; ++i) { /* begin loop to create background */
		x = rand() / 51; /* no more than 100 stars random */
		y = rand() / 68; /* value represent bound to VGA pix*/
		
		//g.setColour (Colour::greyLevel (colorch++));
		//g.fillRect (x, y, 1, 1);
		
		if (colorch > 9) /* bounds check-stay bright colors */
		{ 
			colorch = 4; 
		} 
		else if (colorch == 7) /* FILTER: want a different color */
		{ 
			/* go back to initial color */	
			colorch ++; 
		}
	} /* next two lines are for test only*/	
}

void StarField::updateForeground()
{
	int i, x, y, colorreposit;
	double cosval, sinval, random, startxypos[2] = { width / 2, height / 2 };
	double xstroff = 0.0L, ystroff = 0.0L;
	locstar *star; /* set up star struct */
	
	for (i = 0; i <= starnumber-1; i++) /* loop through starnumber stars */
	{
		newstar (i, star, startxypos, false);
		
		/* create new star now? */
		//stars[i]->pixcolor = 0; /* blank old position movement */
		
		/* wink out star with black */
		//x = (int) stars[i]->xpos; /* convert to integer and display */
		//y = (int) stars[i]->ypos;
		
		//int starColor = stars[i]->pixcolor;
		//g.setColour (Colour::greyLevel (stars[i]->pixcolor));
		//g.fillRect (x, y, 5, 5);
		
		/* shading star depending on loc */
		//shading (i, star, startxypos);
		
		/* update new position */
		updateTrajectory (i, star, startxypos);
		
		//edgeblnkout (g, i, star); /* blink out star when @ scrn edge */
		
		steering (&startxypos[2]); /* steer heading left or right */
	}	
}

void StarField::updateTrajectory (int i, locstar *star, double startxypos[])
{
	double speed;
	int x, y;
	
	stars[i]->zangle = (stars[i]->zangle * 1.25L);
	// stars[i]->zangle *= 100.L;	
	if( stars[i]->zangle > 90.0 ) {
		stars[i]->zangle = 90.0L; /*adj sense depth*/
	}
	
	if ( !( i % 3 ) ) /* pick stars div by 3 */		
	{
		speed = 1.5L * ovrlcnst;
		updpos (i, star, speed);
	} else if ( !( i % 2 ) ) /* pick stars div by 2 */
	{
		speed = 6.5L * ovrlcnst;
		updpos (i, star, speed);
	} else {
		speed = 12.0L* ovrlcnst;
		updpos (i, star, speed);
	}
	
	x = (int) stars[i]->xpos; /* convert to integer and display */
	y = (int) stars[i]->ypos;
	
	int starColor = stars[i]->pixcolor;
	//g.setColour (Colour::greyLevel (stars[i]->pixcolor));
	//g.setColour (Colours::white);
	//g.fillRect (x * 20, y * 20, 15, 15);	
}

void StarField::shading (int i, locstar *star, double startxypos[])
{
	double xpixwnd;
	
	xpixwnd = startxypos[0] - centerx;
	if (stars[i]->xpos < (xpixoffrt + xpixwnd) &&
		stars[i]->ypos < ypixoffbot &&
		stars[i]->xpos > (xpixofflft + xpixwnd) &&
		stars[i]->ypos > ypixofftop)
	{
		stars[i]->pixcolor = 0;
	} else if (stars[i]->xpos > (xpixbrtrt + xpixwnd) ||
			   stars[i]->ypos > ypixbrtbot ||
			   stars[i]->xpos < (xpixbrtlft + xpixwnd) ||
			   stars[i]->ypos < ypixbrttop)
	{
		stars[i]->pixcolor = 15; /* restore it */
	} else {
		stars[i]->pixcolor = 11;
	}		
}

void StarField::newstar (int i, locstar *star, double startxypos[], int initial)
{
	double xstroff = 0.0L, ystroff = 0.0L, random;
	
	if (xstroff > 40.0L || ystroff < -25.0L) {
		xstroff = ystroff = 0.0L; /* limit excursion from center */
	}
	
	if (initial || stars[i]->xpos <= 0.0 || stars[i]->ypos <= 0.0
		|| stars[i]->xpos >= width || stars[i]->ypos >= height)
	{
		random = (rand() / 91.0L); /* get rand number norm 0-360 */
		stars[i]->xyangle = random; /* remember the angle */
		stars[i]->zangle = 0.2L; /* distance at infinity */
		stars[i]->sinanginc = degsin (random); /* obtain trig values */
		stars[i]->cosanginc = degcos (random);		
		stars[i]->xpos = startxypos[0] + xstroff++; /* initial position */		
		stars[i]->ypos = startxypos[1] + ystroff--; /* but not all same place */		
	}		
}

void StarField::steering (double *startxypos)
{
	int keyboard;
	
	if (startxypos[0] < 320.0L) {
		startxypos[0] += 2.0L;
	} else if (startxypos[0] > 320.0L)	{
		startxypos[0] -= 2.0L;
	}	
}

void StarField::edgeblnkout (Graphics& g, int i, locstar *star)
{
	int x, y;
	
	/* when the star reaches the border blank it out */
	if (stars[i]->xpos <= 5.0 || stars[i]->ypos <= 5.0
		|| stars[i]->xpos >= width || stars[i]->ypos >= height)
	{
		stars[i]->pixcolor = 0;
		x = (int) stars[i]->xpos; /* convert to integer and display */
		y = (int) stars[i]->ypos;
		
		g.setColour (Colour::greyLevel (stars[i]->pixcolor));
		g.fillRect (x, y, 1, 1);
	}	
}

void StarField::updpos (int i, locstar *star, double speed)
{
	//int i;
	stars[i]->xpos += (stars[i]->cosanginc *
					   (speed * degsin(stars[i]->zangle) ));
	stars[i]->ypos += stars[i]->sinanginc * (speed * degsin(stars[i]->zangle));
}

double StarField::degsin (double degreeinput)
{
	double sinvalue;
	double sininput;
	
	sininput = (0.0174527L * degreeinput); /* multiply by constant for deg*/
	
	sinvalue = sin (sininput); /* get the trig value */
	
	return (sinvalue); /* pass by value to caller */	
}

double StarField::degcos (double degreeinput)
{
	double cosvalue;
	double cosinput;
	
	cosinput = (0.0174527L * degreeinput); /* multiply by constant for deg*/
	cosvalue = cos (cosinput); /* get the trig value */
	
	return (cosvalue); /* pass by value to caller */		
}

void StarField::steereffct (locstar *star, double startxypos[])
{
	static double drift = 0;
	static double prevdrift;
	double warptraject;
	static int starcnt = 0;
	int x, y, i;
	
	/* actual drift noticed? */		
	if (drift) {
		/* then we are in a turn */
		if( ++starcnt > starnumber ) { 
			/* by this code drift val*/
			starcnt = drift = 0; /* will freeze for size */
		} /* of stars */
		
		stars[i]->sinanginc = degsin (stars[i]->xyangle);
		stars[i]->cosanginc = degcos (stars[i]->xyangle);
	} else {
		drift = startxypos[0] - prevdrift; /* moved center turning? */
		prevdrift = startxypos[0];
	}	
}



