/*
 *  MainComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/4/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef MainComponent_H
#define MainComponent_H

#include "JuceHeader.h"

class PluginAudioProcessor;
class SequencerComponent;
class OptionsComponent;
class SidebarComponent;

class MainComponent : 
public Component,
public Timer
{
public:
	MainComponent (PluginAudioProcessor* pluginAudioProcessor_);
	~MainComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	
	// Timer methods
	virtual void timerCallback();

private:
	// Time conversion methods
	static const String timeToTimecodeString (const double seconds);
	static const String ppqToBarsBeatsString (double ppq, int numerator, int denominator);
	
	PluginAudioProcessor* pluginAudioProcessor;

	Label* positionLabel;	
	AudioPlayHead::CurrentPositionInfo lastDisplayedPosition;
	
	SequencerComponent* sequencerComponent;
	OptionsComponent* optionsComponent;
	SidebarComponent* sidebarComponent;
};

#endif
