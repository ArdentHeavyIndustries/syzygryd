/*
 *  AdjustmentComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/15/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef AdjustmentComponent_H
#define AdjustmentComponent_H

#include "JuceHeader.h"

class PluginAudioProcessor;
class Sequencer;

class AdjustmentComponent : 
public Component,
public Timer,
public SliderListener
{
public:
	AdjustmentComponent (PluginAudioProcessor* pluginAudioProcessor_);
	~AdjustmentComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

	// Timer methods
	virtual void timerCallback();

	// SliderListener methods
    virtual void sliderValueChanged (Slider* slider);
	
private:
	PluginAudioProcessor* pluginAudioProcessor;
	Sequencer* sequencer;
	
	Slider* noteLengthSlider;
	int lastNoteLength;
};

#endif
