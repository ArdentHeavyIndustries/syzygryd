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
public Component,
public Timer
{
public:
	MainComponent();
	~MainComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	
	// Timer methods
	virtual void timerCallback();
	
private:
	MyOpenGLComponent* myOpenGLComponent;
	TextEditor* dataText;
	
	String lastData;
};

#endif
