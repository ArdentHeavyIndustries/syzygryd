/*
 *  PanelComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef PanelComponent_H
#define PanelComponent_H

#include "JuceHeader.h"

class Sequencer;

class PanelComponent : public Component
{
public:
	PanelComponent (Sequencer* sequencer_);
	~PanelComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

private:
	Sequencer* sequencer;
};

#endif
