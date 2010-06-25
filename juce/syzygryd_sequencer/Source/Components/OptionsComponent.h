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

class Sequencer;

class OptionsComponent : 
public Component,
public ButtonListener
{
public:
	OptionsComponent (Sequencer* sequencer_);
	~OptionsComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

	// ButtonListener methods
	virtual void buttonClicked (Button* button);	
	
private:
	Sequencer* sequencer;
	
	ToggleButton* swingButton;
	ToggleButton* dynamicsButton;	
};

#endif
