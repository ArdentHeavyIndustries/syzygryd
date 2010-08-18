/*
 *  MyOpenGLComponent.h
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 4/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef MY_OPEN_GL_COMPONENT_H
#define MY_OPEN_GL_COMPONENT_H

#include "JuceHeader.h"

class MyOpenGLComponent : 
public OpenGLComponent,
public Timer
{
public:
	MyOpenGLComponent();
	~MyOpenGLComponent();

	const String& getLastData();
	
	// OpenGLComponent methods
	virtual void renderOpenGL();
	virtual void newOpenGLContextCreated();
	virtual void mouseDrag (const MouseEvent& e);
	
	// Timer methods
	virtual void timerCallback();

private:
	void set_projection();
	void reset_camera();
	void cam_zoom( float delta );
	

};

#endif
