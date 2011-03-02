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

#if JUCE_WINDOWS
#include <hash_map>
using std::hash_map;
#else
// mac
#include <ext/hash_map>
// copied from http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=295052
 #  if (defined(__GNUC__) && (((__GNUC__ == 3) && ( __GNUC_MINOR__ > 0)) || __GNUC__ >= 4))
 using __gnu_cxx::hash_map;
 #  else
 using std::hash_map;
 #  endif
#endif

class Cell;
class Panel;

class OscInput;
class OscOutput;

// This class is the single shared resource between instances of the plugin
class SharedState : public DeletedAtShutdown
{
public:
   static const String kConfigFile;
   // hash_map doesn't work with a JUCE String as a Key
   // with std::hash_map (windows), we can use an int64 as the Key
   // with __gnu_cxx::hash_map (mac), this doesn't work
   // we could condition all uses of this to be either a 32b or 64b hash for
   // the key, but it's just not worth it, as our probability of collision is
   // so low, and the mac is the "real" platform anyway.  so just use int32
   // everywhere for convenience (aka laziness)
   static hash_map<int32, String> config;

	static const int kNumPanels;
   // bug:67
   static int kDegradeAfterInactiveSec;	// set to a negative value to disable
   static int kDegradeSlowSec;
   static int kDegradeSlowSecPerDelete;
   static int kDegradeFastSec;
   // in fast mode, the slowest rate (so max secPerDelete) is the same as the slow rate
   // the fastest rate (so min secPerDelete) is whatever is needed to delete all cells in the allotted time

   static String kBroadcastIpAddr;

   // bug:86
   void readConfig();
   String getConfigString(String key, String defaultValue);
   int getConfigInt(String key, int defaultValue);
	
	bool testAndSetPrimarySequencer();
	
	int getTotalRows();
	int getTotalCols();
	
	int getTabIndex (int panelIndex_);
	void setTabIndex (int panelIndex_, int tabIndex_);	
	
	int getPlayheadCol(); // only used for playhead transmission
	
	float getPlayheadColPrecise(); // only used for playhead transmission
	void setPlayheadColPrecise (float playheadColPrecise_);
	
	float getPpqPosition();
	void setPpqPosition (float ppqPosition_);
	
	float getTimeInSeconds();
	void setTimeInSeconds (float timeInSeconds_);
	
	float getBpm();
	void setBpm (float bpm_);
	
	Cell* getCellAt (int panelIndex_, int tabIndex_, int row_, int col_);
	void broadcast (const void* sourceBuffer, int numBytesToWrite);
	
	void noteToggle (int panelIndex_, int tabIndex_, int row_, int col_, 
                    bool state);
	void clearTab (int panelIndex_, int tabIndex_, bool fromStopAttract_);
   void clearCurrentTab (int panelIndex_, bool fromStopAttract_);
	void clearTab (int panelIndex_, int tabIndex_);
   void clearCurrentTab (int panelIndex_);
	
	osc::Blob* updateAndGetCompressedPanelState (int panelIndex_); 
	String getStringPanelState (int panelIndex_); 
	void setStringPanelState (int panelIndex_, String state);

   void sendInefficientSync(int panelIndex_);
   void sendInefficientClearTab(int panelIndex_, int tabIndex_);

   void updateLastTouch(int panelIndex_);
	
	void updateStarField();
	bool getStarFieldActive();
	void setStarFieldActive (bool starFieldActive_);
   void enableStarField();
   void disableStarField();

   // bug:67
	int64 getLastTouchElapsedMs (int panelIndex_);
   int getState (int panelIndex_);
   void startDegrade (int panelIndex_);
   void degradeStep (int panelIndex_);
   bool allDegraded();
   void startAttract();
#ifdef JUCE_DEBUG
   bool allAttracting();
#endif
   void stopAttract();

	int getUpdateStarFieldSkip();
	void setUpdateStarFieldSkip (int updateStarFieldSkip_);	
	
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
	
	float playheadColPrecise; // only used for playhead transmission
	float ppqPosition;
	float timeInSeconds;
	float bpm;
	
	OwnedArray<Panel> panels; // holds actual notation
	
	OscInput* oscInput;
	OscOutput* oscOutput;

   // XXX bug:79 - it would be better to keep a list of IP addresses, but i
   // don't know how to get that info
   bool* touchOscConnected;
	
	bool starFieldActive; // perform starfield effect	
	int updateStarFieldSkip; // star field playback rate (higher = slower)
};

#endif
