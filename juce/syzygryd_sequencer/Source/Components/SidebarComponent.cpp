/*
 *  SidebarComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Sequencer.h"

#include "SidebarComponent.h"
#include "PanelComponent.h"

const int kNumPanels = 4;

SidebarComponent::SidebarComponent (Sequencer* sequencer_) :
Component ("SidebarComponent"),
sequencer (sequencer_)
{
	for (int i = 0; i < kNumPanels; i++) {
		PanelComponent* panel;
		addAndMakeVisible (panel = new PanelComponent (sequencer));
		panelComponents.add (panel);
	}
	
}

SidebarComponent::~SidebarComponent()
{
	deleteAllChildren();
}

// Component methods
void SidebarComponent::paint (Graphics& g)
{
	g.fillAll (Colour::fromRGB (120, 150, 140));
}

void SidebarComponent::resized()
{
	for (int i = 0; i < kNumPanels; i++) {
		PanelComponent* panel = panelComponents[i];
		float panelHeight = (float)getHeight() / kNumPanels;
		panel->setBounds (0, i * panelHeight, getWidth(), panelHeight);
	}
}

