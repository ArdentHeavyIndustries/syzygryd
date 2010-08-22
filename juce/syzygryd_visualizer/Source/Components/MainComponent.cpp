/*
 *  MainComponent.cpp
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "MyOpenGLComponent.h"

#include "MainComponent.h"

MainComponent::MainComponent() :
Component (T("Main Component")),
myOpenGLComponent (0)
{
	addAndMakeVisible (myOpenGLComponent = new MyOpenGLComponent());

	setSize (600, 400);
}

MainComponent::~MainComponent()
{
	deleteAllChildren();
}

// Component methods
void MainComponent::paint (Graphics& g)
{
	g.fillAll (Colours::grey);
}

void MainComponent::resized()
{
	myOpenGLComponent->setBounds (10, 10, getWidth() - 20, getHeight() - 20);
}





