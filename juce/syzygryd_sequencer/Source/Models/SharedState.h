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
	void clearTab (int panelIndex_, int tabIndex_);

	void broadcast (const void* sourceBuffer, int numBytesToWrite);
	
	juce_DeclareSingleton (SharedState, true)
	
private:
	SharedState();
	~SharedState();

	const int totalRows;
	const int totalCols;	
	
	int playheadCol; // only used for playhead transmission
	
	OwnedArray<Panel> panels; // holds actual notation

	OscInput* oscInput;
	OscOutput* oscOutput;
};

#endif
