/*
 *  TabComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PluginAudioProcessor.h"
#include "Sequencer.h"

#include "TabComponent.h"

TabComponent::TabComponent (PluginAudioProcessor* pluginAudioProcessor_, int index_) :
Component ("TabComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
index (index_)
{
	sequencer = pluginAudioProcessor->getSequencer();
}

TabComponent::~TabComponent()
{
	deleteAllChildren();
}

// Component methods
void TabComponent::paint (Graphics& g)
{
	g.fillAll (Colour::fromRGB (30, 30, 30));
	if (pluginAudioProcessor->getTabIndex() == index) {
		g.setColour (Colour::fromRGB (20, 80, 70));
		g.fillRect (0, 1, getWidth(), getHeight() - 2);
	}
	g.setColour (Colour::fromRGB (120, 180, 170));
	g.drawRect (0, 1, getWidth(), getHeight() - 2, 1.0);	
}

void TabComponent::resized()
{
}

void TabComponent::mouseDown (const MouseEvent& e)
{
	pluginAudioProcessor->setTabIndex (index);
	repaint();
}


