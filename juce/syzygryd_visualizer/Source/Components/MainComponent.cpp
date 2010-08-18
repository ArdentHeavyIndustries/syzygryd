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
myOpenGLComponent (0),
dataText (0)
{
	addAndMakeVisible (myOpenGLComponent = new MyOpenGLComponent());
	addAndMakeVisible (dataText = new TextEditor ("dataLabel"));

	Font dataFont (10);
	dataFont.setTypefaceName (Font::getDefaultMonospacedFontName());
	
	dataText->setText ("No data received.", false);
	dataText->setMultiLine (true, true);
	dataText->setFont (dataFont);
	
	setSize (600, 400);
	
	startTimer (50);
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
	myOpenGLComponent->setBounds (10, 10, getWidth() - 20, getHeight() - 100);
	dataText->setBounds (10, getHeight() - 80, getWidth() - 20, 70);
}

// Timer methods
void MainComponent::timerCallback()
{
	if (lastData != myOpenGLComponent->getLastData()) {
		lastData = myOpenGLComponent->getLastData();
		dataText->setText (lastData, false);
		repaint();
	}
}




