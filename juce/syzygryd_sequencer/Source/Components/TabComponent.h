/*
 *  TabComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef TabComponent_H
#define TabComponent_H

#include "JuceHeader.h"

class PluginAudioProcessor;
class Sequencer;

class TabComponent : public Component
{
public:
	TabComponent (PluginAudioProcessor* pluginAudioProcessor_, int index_);
	~TabComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	virtual void mouseDown (const MouseEvent& e);

private:
	PluginAudioProcessor* pluginAudioProcessor;
	Sequencer* sequencer;

	int index; // this tab's id number
};

#endif
