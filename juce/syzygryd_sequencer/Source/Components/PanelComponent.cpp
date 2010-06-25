/*
 *  PanelComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PanelComponent.h"


PanelComponent::PanelComponent (Sequencer* sequencer_) :
Component ("PanelComponent"),
sequencer (sequencer_)
{
}

PanelComponent::~PanelComponent()
{
}

// Component methods
void PanelComponent::paint (Graphics& g)
{
	g.fillAll (Colour::fromRGB (30, 30, 30));
	g.setColour (Colour::fromRGB (120, 180, 170));
	g.drawRect (0, 0, getWidth(), getHeight(), 1.0);
}

void PanelComponent::resized()
{
}

