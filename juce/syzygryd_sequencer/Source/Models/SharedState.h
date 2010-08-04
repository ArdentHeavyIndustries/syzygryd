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
	static const int kNumPanels;

   bool testAndSetPrimarySequencer();
	
	int getTotalRows();
	int getTotalCols();
	
	int getTabIndex (int panelIndex_);
	void setTabIndex (int panelIndex_, int tabIndex_);	
	
	int getPlayheadCol(); // only used for playhead transmission
	
	double getPlayheadColPrecise(); // only used for playhead transmission
	void setPlayheadColPrecise (int playheadColPrecise_);
	
	double getPpqPosition();
	void setPpqPosition (double ppqPosition_);
	
	double getTimeInSeconds();
	void setTimeInSeconds (double timeInSeconds_);
	
	double getBpm();
	void setBpm (double bpm_);
	
	Cell* getCellAt (int panelIndex_, int tabIndex_, int row_, int col_);
	void broadcast (const void* sourceBuffer, int numBytesToWrite);
	
	void noteToggle (int panelIndex_, int tabIndex_, int row_, int col_, 
					 bool state);
	void clearTab (int panelIndex_, int tabIndex_);
	
	osc::Blob* updateAndGetCompressedPanelState (int panelIndex_); 
	String getStringPanelState (int panelIndex_); 
	void setStringPanelState (int panelIndex_, String state);

   void sendInefficientSync();
   void sendInefficientClearTab(int panelIndex_, int tabIndex_);
	
	void update();

	bool getStarFieldActive();
	void setStarFieldActive (bool starFieldActive_);

	juce_DeclareSingleton (SharedState, true)
	
private:
	SharedState();
	~SharedState();

   CriticalSection primarySequencerCriticalSection;
   bool primarySet;
	
	const int totalRows;
	const int totalCols;	
	
	osc::Blob** blobs;
	int paddingBits;
	
	double playheadColPrecise; // only used for playhead transmission
	double ppqPosition;
	double timeInSeconds;
	double bpm;
	
	OwnedArray<Panel> panels; // holds actual notation
	
	OscInput* oscInput;
	OscOutput* oscOutput;

   // XXX bug:72,76 - it would be better to keep a list of IP addresses, but i
   // don't know how to get that info
   // XXX bug:77 i suspect that maybe this should be per panel
   bool touchOscConnected;
	
	bool starFieldActive; // perform starfield effect	
};

#endif
