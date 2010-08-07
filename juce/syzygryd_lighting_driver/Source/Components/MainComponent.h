/*
 *  MainComponent.h
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef MAIN_COMPONENT_H
#define MAIN_COMPONENT_H

#include "JuceHeader.h"

class Lighting;

class MainComponent : 
public Component,
public ButtonListener
{
public:
	MainComponent();
	~MainComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

	// ButtonListener methods
	virtual void buttonClicked (Button* button);
	
private:
	Lighting* lighting;
	
	TextButton* sendButton;
	TextButton* stopButton;
};

#endif
