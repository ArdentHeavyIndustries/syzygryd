/*
 *  OptionsComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Sequencer.h"

#include "OptionsComponent.h"

OptionsComponent::OptionsComponent (Sequencer* sequencer_):
Component ("OptionsComponent"),
sequencer (sequencer_),
swingButton (0),
dynamicsButton (0)
{
	addAndMakeVisible (swingButton = new ToggleButton ("Swing"));
	swingButton->setColour (ToggleButton::textColourId, Colour::fromRGB (150, 150, 150));
	swingButton->addButtonListener (this);
	
	addAndMakeVisible (dynamicsButton = new ToggleButton ("Dynamics"));
	dynamicsButton->setColour (ToggleButton::textColourId, Colour::fromRGB (150, 150, 150));
	dynamicsButton->addButtonListener (this);

}

OptionsComponent::~OptionsComponent()
{
}

// Component methods
void OptionsComponent::paint (Graphics& g)
{
}

void OptionsComponent::resized()
{
	swingButton->setBounds (0, 0, getWidth(), 20);
	swingButton->setToggleState (sequencer->getSwingEnabled(), false);
	dynamicsButton->setBounds (0, 20, getWidth(), 20);
	dynamicsButton->setToggleState (sequencer->getDynamicsEnabled(), false);
}

// ButtonListener methods
void OptionsComponent::buttonClicked (Button* button)
{
	if (button == swingButton) {
		sequencer->setSwingEnabled (swingButton->getToggleState());
	} else if (button == dynamicsButton) {
		sequencer->setDynamicsEnabled (dynamicsButton->getToggleState());
	}	
}



