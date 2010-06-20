/*
 *  StandaloneComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/7/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef StandaloneComponent_H
#define StandaloneComponent_H

#include "JuceHeader.h"

class TransportComponent;

class StandaloneComponent : public Component
{
public:
	StandaloneComponent (AudioProcessorEditor* audioProcessorEditor_);
	~StandaloneComponent();
	
	AudioProcessorEditor* getAudioProcessorEditor();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();	
	
private:
	AudioProcessorEditor* audioProcessorEditor;
	TransportComponent* transportComponent;
};

#endif
