/*
 *  SidebarComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PluginAudioProcessor.h"
#include "Sequencer.h"

#include "SidebarComponent.h"
#include "TabComponent.h"

const int kNumTabs = 4;

SidebarComponent::SidebarComponent (PluginAudioProcessor* pluginAudioProcessor_) :
Component ("SidebarComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
lastPanelIndex (-1),
lastTabIndex (-1),
clearButton (0)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	for (int i = 0; i < kNumTabs; i++) {
		TabComponent* tab;
		addAndMakeVisible (tab = new TabComponent (pluginAudioProcessor, i));
		tabComponents.add (tab);
	}
	
	addAndMakeVisible (clearButton = new TextButton ("Clear"));
	clearButton->addButtonListener (this);
	
	startTimer (100);
}

SidebarComponent::~SidebarComponent()
{
	stopTimer();
	deleteAllChildren();
}

// Component methods
void SidebarComponent::paint (Graphics& g)
{
	//g.fillAll (Colour::fromRGB (120, 150, 140));
}

void SidebarComponent::resized()
{
	for (int i = 0; i < kNumTabs; i++) {
		TabComponent* tab = tabComponents[i];
		float tabHeight = 40;
		tab->setBounds (5, i * tabHeight, getWidth() - 5, tabHeight);
	}
	
	clearButton->setBounds (5, 170, getWidth() - 5, 30);
}

// Timer methods
void SidebarComponent::timerCallback()
{
	if (lastPanelIndex != pluginAudioProcessor->getPanelIndex()
		|| lastTabIndex != pluginAudioProcessor->getTabIndex()) {
		lastPanelIndex = pluginAudioProcessor->getPanelIndex();
		lastTabIndex = pluginAudioProcessor->getTabIndex();
		
		for (int i = 0; i < kNumTabs; i++) {
			TabComponent* tab = tabComponents[i];
			tab->repaint();
		}	
	}
}

// ButtonListener methods
void SidebarComponent::buttonClicked (Button* button)
{
	if (button == clearButton) {
		int panelIndex = pluginAudioProcessor->getPanelIndex();
		int tabIndex = pluginAudioProcessor->getTabIndex();
		sequencer->clearTab (panelIndex, tabIndex);
	}
}




