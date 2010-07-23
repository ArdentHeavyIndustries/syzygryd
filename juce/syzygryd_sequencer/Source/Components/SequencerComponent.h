/*
 *  SequencerComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef SequencerComponent_H
#define SequencerComponent_H

#include "JuceHeader.h"

class Cell;
class PluginAudioProcessor;
class Sequencer;
class CellComponent;

class SequencerComponent : 
public Component,
public Timer
{
public:
	SequencerComponent (PluginAudioProcessor* pluginAudioProcessor_);
	~SequencerComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	virtual void mouseDown (const MouseEvent& e);
	virtual void mouseDrag (const MouseEvent& e);
	
	// Timer methods
	virtual void timerCallback();
	
private:
	CellComponent* getCellAt (int row, int col);
	void handleMouseEvent (const MouseEvent& e, bool alwaysToggle);
	
	PluginAudioProcessor* pluginAudioProcessor;
	Sequencer* sequencer;
	
	OwnedArray< Array<CellComponent*> > rows;
	
	int lastPlayheadCol;
	
	int lastPanelIndex;
	int lastTabIndex;
	
	CellComponent* lastToggledCellComponent;
};

#endif

