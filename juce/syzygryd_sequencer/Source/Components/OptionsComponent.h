/*
 *  OptionsComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef OptionsComponent_H
#define OptionsComponent_H

#include "JuceHeader.h"

class PluginAudioProcessor;
class Sequencer;

class OptionsComponent : 
public Component,
public ButtonListener,
public Timer
{
public:
	OptionsComponent (PluginAudioProcessor* pluginAudioProcessor_);
	~OptionsComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

	// ButtonListener methods
	virtual void buttonClicked (Button* button);	
	
	// Timer methods
	virtual void timerCallback();
	
private:
	PluginAudioProcessor* pluginAudioProcessor;
	Sequencer* sequencer;
	
	OwnedArray<TextButton> panelButtons;

	int lastPanelIndex;
};

#endif
