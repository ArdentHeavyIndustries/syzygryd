/*
 *  CellComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef CellComponent_H
#define CellComponent_H

#include "JuceHeader.h"

class Cell;
class PluginAudioProcessor;
class Sequencer;

class CellComponent : public Component
{
public:
	CellComponent (PluginAudioProcessor* pluginAudioProcessor_, Cell* cell_);
	~CellComponent();
	
	void setCell (Cell* cell_);
	void toggleNote();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

private:
	PluginAudioProcessor* pluginAudioProcessor;	
	Sequencer* sequencer;
	
	Cell* cell;	
};

#endif
