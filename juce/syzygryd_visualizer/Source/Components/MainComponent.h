/*
 *  MainComponent.h
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef MAIN_COMPONENT_H
#define MAIN_COMPONENT_H

class MyOpenGLComponent;

#include "JuceHeader.h"

class MainComponent : 
public Component
{
public:
	MainComponent();
	~MainComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	
private:
	MyOpenGLComponent* myOpenGLComponent;
};

#endif
