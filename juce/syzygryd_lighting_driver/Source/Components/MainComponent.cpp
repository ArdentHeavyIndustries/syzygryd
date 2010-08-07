/*
 *  MainComponent.cpp
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Lighting.h"

#include "MainComponent.h"

MainComponent::MainComponent() :
Component (T("Main Component")),
lighting (0),
sendButton (0),
stopButton (0)
{
	addAndMakeVisible (sendButton = new TextButton ("Send"));
	sendButton->addButtonListener (this);

	addAndMakeVisible (stopButton = new TextButton ("Stop"));
	stopButton->addButtonListener (this);
	
	lighting = new Lighting();
	
	setSize (600, 400);
}

MainComponent::~MainComponent()
{
	lighting->stopThread (3000);
	deleteAndZero (lighting);
	
	deleteAllChildren();
}

// Component methods
void MainComponent::paint (Graphics& g)
{
	g.fillAll (Colours::grey);
}

void MainComponent::resized()
{
	sendButton->setBounds (10, 10, 100, 40);
	stopButton->setBounds (10, 60, 100, 40);
}

// ButtonListener methods
void MainComponent::buttonClicked (Button* button)
{
	if (button == sendButton) {
		lighting->startThread();
	} else if (button = stopButton) {
		lighting->stopThread (3000);
	}
}


