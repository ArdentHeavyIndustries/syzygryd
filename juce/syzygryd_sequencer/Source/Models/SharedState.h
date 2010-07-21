/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  SharedState.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef SharedState_H
#define SharedState_H

#include "osc/OscTypes.h"

#include "JuceHeader.h"

class Cell;
class Panel;

class OscInput;
class OscOutput;

// This class is the single shared resource between instances of the plugin
class SharedState : public DeletedAtShutdown
{
public:
	int getTotalRows();
	int getTotalCols();

	int getTabIndex (int panelIndex_);
	void setTabIndex (int panelIndex_, int tabIndex_);	
	
	int getPlayheadCol(); // only used for playhead transmission
	void setPlayheadCol (int playheadCol_);
	
	Cell* getCellAt (int panelIndex_, int tabIndex_, int row_, int col_);
	void broadcast (const void* sourceBuffer, int numBytesToWrite);
	
	void noteToggle (int panelIndex_, int tabIndex_, int row_, int col_, 
					 bool state);
	void clearTab (int panelIndex_, int tabIndex_);

   osc::Blob* updateAndGetCompressedPanelState (int panelIndex_); 
	String getStringPanelState (int panelIndex_); 
	void setStringPanelState (int panelIndex_, String state);
	
	juce_DeclareSingleton (SharedState, true)
	
private:
	SharedState();
	~SharedState();

	const int totalRows;
	const int totalCols;	

   osc::Blob** blobs;
   int paddingBits;
	
	int playheadCol; // only used for playhead transmission
	
	OwnedArray<Panel> panels; // holds actual notation

	OscInput* oscInput;
	OscOutput* oscOutput;
};

#endif
