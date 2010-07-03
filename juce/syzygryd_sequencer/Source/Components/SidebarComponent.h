/*
 *  SidebarComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef SidebarComponent_H
#define SidebarComponent_H

#include "JuceHeader.h"

class PluginAudioProcessor;
class Sequencer;
class TabComponent;

class SidebarComponent : 
public Component,
public Timer,
public ButtonListener
{
public:
	SidebarComponent (PluginAudioProcessor* pluginAudioProcessor_);
	~SidebarComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	
	// Timer methods
	virtual void timerCallback();

	// ButtonListener methods
	virtual void buttonClicked (Button* button);
	
private:
	PluginAudioProcessor* pluginAudioProcessor;
	Sequencer* sequencer;
	
	Array<TabComponent*> tabComponents;
	Button* clearButton;
	
	int lastPanelIndex;
	int lastTabIndex;
};

#endif
