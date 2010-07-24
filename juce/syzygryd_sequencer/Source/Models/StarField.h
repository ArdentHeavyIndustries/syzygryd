/*
 *  StarField.h
 *  starfield2
 *
 *  Created by Matt Sonic on 7/23/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

// Original Code: http://www.cs.okstate.edu/~twright/BCCSTAR.htm
// programmer: T Wright
// dated: August 1, 1993

#ifndef StarField_H
#define StarField_H

#include "JuceHeader.h"

/* structure definitions */
typedef struct starpos
{
	double xpos;
	double ypos;
	int pixcolor;
	double xyangle;
	double zangle;
	double sinanginc;
	double cosanginc;
} locstar;

class Star {
public:
	Star() :
	xpos (0),
	ypos (0),
	pixcolor (0),
	xyangle (0),
	zangle (0),
	sinanginc (0),
	cosanginc (0)
	{
	}
	
	~Star() { }
	
	double xpos;
	double ypos;
	int pixcolor;
	double xyangle;
	double zangle;
	double sinanginc;
	double cosanginc;	
};

class StarField 
{
public:
	StarField (int rows, int cols);
	~StarField();
	
	void update();
	bool getActiveAt (int row, int col);
	
	int getRows();
	int getCols();
	
private:
	void updateBackground();
	void updateForeground();	
	void updateTrajectory(int i, locstar *star, double startxypos[]);
	
	void shading (int i, locstar *star, double startxypos[]);
	void newstar (int i, locstar *star, double startxypos[], int initial); 
	void steering (double *startxypos);
	void edgeblnkout (Graphics& g, int i, locstar *star);
	void updpos (int i, locstar *star, double speed);
	double degsin (double degreeinput);
	double degcos (double degreeinput);
	void steereffct (locstar *star, double startxypos[]);
	
	OwnedArray<Star> stars;
	
	float ovrlcnst;
	
	int width;
	int height;
	
	int starnumber; /* the number of stars to see */
	int xpixoffrt; /* boundry center blank-out stars */
	int ypixofftop; /* left and right top and bottom */
	int xpixofflft; 
	int ypixoffbot;
	int xpixbrtrt; /* boundry where stars brighten for*/
	int ypixbrttop; /* them traveling closer */
	int xpixbrtlft;
 	int ypixbrtbot;
	int centerx; /* initial center field of view */
	
};

#endif
