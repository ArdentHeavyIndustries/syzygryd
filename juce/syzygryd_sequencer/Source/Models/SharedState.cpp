/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  SharedState.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "Panel.h"
#include "OscInput.h"
#include "OscOutput.h"
#include "Panel.h"

#include "SharedState.h"

const int SharedState::kNumPanels = 3;

// bug:67
// XXX it would be much better if we could set these as runtime properties and not have to recompile
const int SharedState::kDegradeAfterInactiveSec = 120;	// set to a negative value to disable
const int SharedState::kDegradeSlowSec = 30;
const int SharedState::kDegradeSlowSecPerDelete = 3;
const int SharedState::kDegradeFastSec = 270;
// in fast mode, the slowest rate (so max secPerDelete) is the same as the slow rate
// the fastest rate (so min secPerDelete) is whatever is needed to delete all cells in the alloted time
// below is for testing...
// const int SharedState::kDegradeAfterInactiveSec = 30;
// //const int SharedState::kDegradeAfterInactiveSec = -1;	// test disable
// const int SharedState::kDegradeSlowSec = 10;
// const int SharedState::kDegradeSlowSecPerDelete = 3;
// const int SharedState::kDegradeFastSec = 30;

juce_ImplementSingleton (SharedState)

SharedState::SharedState() :
primarySet (false),
totalRows (10),
totalCols (16),
oscInput (0),
oscOutput (0),
ppqPosition (0.0),
timeInSeconds (0.0),
bpm (120.0),
starFieldActive (false)
{
	blobs = new osc::Blob*[kNumPanels];
	touchOscConnected = new bool[kNumPanels];
	int numValues = Panel::kNumTabs * totalRows * totalCols;
	int numBytes = numValues / (sizeof(unsigned char)*8);
	int numBits = numBytes * (sizeof(unsigned char)*8);
	paddingBits = numValues - numBits;
	if (paddingBits > 0) {
		numBytes++;
	}
	
	for (int i = 0; i < kNumPanels; i++) {
		Panel* panel = new Panel (totalRows, totalCols, i);
		panels.add (panel);
		
		blobs[i] = new osc::Blob();
		unsigned char* values = (unsigned char*)calloc(numBytes, sizeof(unsigned char));
		blobs[i]->data = (void*) values;
		blobs[i]->size = numBytes * sizeof(unsigned char);
		
		touchOscConnected[i] = false;
	}
	
	oscInput = new OscInput();
	oscOutput = new OscOutput();
}

SharedState::~SharedState()
{
	deleteAndZero (oscInput);
	deleteAndZero (oscOutput);
	
	for (int i = 0; i < kNumPanels; i++) {
		free((unsigned char*) blobs[i]->data);
		delete blobs[i];
	}
	delete [] blobs;
	delete [] touchOscConnected;
}

bool SharedState::testAndSetPrimarySequencer()
{
	const ScopedLock primarySequencerScopedLock (primarySequencerCriticalSection);
	// critical section is now locked
	
	// bug:51 - whichever sequencer calls this first gets to be the primary one.
	bool retValue;
	if (!primarySet) {
		primarySet = true;
		retValue = true;
	} else {
		retValue = false;
	}
	
	// critical section gets unlocked here
	return retValue;
}

int SharedState::getTotalRows()
{
	return totalRows;
}

int SharedState::getTotalCols()
{
	return totalCols;
}

int SharedState::getTabIndex (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	return panel->getTabIndex();
}

void SharedState::setTabIndex (int panelIndex_, int tabIndex_)
{
   // DBG(String(Time::currentTimeMillis()) + " "
   //     + "Panel " + String(panelIndex_) + " touched to set tab to " + String(tabIndex_));

	Panel* panel = panels[panelIndex_];
   // XXX bug:67 - switch to Time::currentTimeMillis() ?
	panel->setLastTouchSecond (getTimeInSeconds());
	
	panel->setTabIndex (tabIndex_);
}

int SharedState::getPlayheadCol()
{
	return (int)getPlayheadColPrecise();
}

float SharedState::getPlayheadColPrecise()
{
	return playheadColPrecise;
}

void SharedState::setPlayheadColPrecise (float playheadColPrecise_)
{
	playheadColPrecise = playheadColPrecise_;
}

float SharedState::getPpqPosition()
{
	return ppqPosition;
}

void SharedState::setPpqPosition (float ppqPosition_)
{
	ppqPosition = ppqPosition_;
}

float SharedState::getTimeInSeconds()
{
	return timeInSeconds;
}

void SharedState::setTimeInSeconds (float timeInSeconds_)
{
	timeInSeconds = timeInSeconds_;
}

float SharedState::getBpm()
{
	return bpm;
}

void SharedState::setBpm (float bpm_)
{
	bpm = bpm_;
}

Cell* SharedState::getCellAt (int panelIndex_, int tabIndex_, int row_, int col_)
{
	Panel* panel = panels[panelIndex_];
	return panel->getCellAt (tabIndex_, row_, col_);
}

void SharedState::broadcast (const void* sourceBuffer, int numBytesToWrite)
{
	oscOutput->broadcast (sourceBuffer, numBytesToWrite);
}

void SharedState::noteToggle (int panelIndex_, int tabIndex_, 
                              int row_, int col_, bool state)
{
   // DBG(String(Time::currentTimeMillis()) + " "
   //     + "Panel " + String(panelIndex_) + " touched to set note at tab" + String(tabIndex_) + "/row" + String(row_) + "/col" + String(col_)  + " to " + String(state));

	Panel* panel = panels[panelIndex_];
   // XXX bug:67 - switch to Time::currentTimeMillis() ?
	panel->setLastTouchSecond (getTimeInSeconds());
	
	Cell* cell = getCellAt (panelIndex_, tabIndex_, row_, col_);
	if (state) {
		cell->setNoteOn();
	} else {
		cell->setNoteOff();
	}
	oscOutput->sendNoteToggle (panelIndex_, tabIndex_, row_, col_, state);
}

void SharedState::clearTab (int panelIndex_, int tabIndex_, bool fromStopAttract_)
{
#ifdef JUCE_DEBUG
   if (!fromStopAttract_) {
      DBG (String(Time::currentTimeMillis()) + " "
           + "Panel " + String(panelIndex_) + " touched to clear tab " + String(tabIndex_));
   } else {
      DBG (String(Time::currentTimeMillis()) + " "
           + "Clearing panel " + String(panelIndex_) + " because all panels are being cleared to end attract mode)");
   }
#endif

	// Send inefficient clear to touchOSC controllers.
	// This must be done *before* the actual clear.
	// Only do if needed.
	// XXX bug:79 - not broadcasting would be better
	if (touchOscConnected[panelIndex_]) {
		sendInefficientClearTab (panelIndex_, tabIndex_);
	}
#ifdef JUCE_DEBUG
	else {
		DBG (String(Time::currentTimeMillis()) + " "
           + "Not sending inefficient clear tab for touchOSC compatability to panel="
           + String(panelIndex_) + " tab=" + String(tabIndex_)
           + " because no touchOSC controller has connected yet");
	}
#endif
	Panel* panel = panels[panelIndex_];
   // XXX bug:67 - switch to Time::currentTimeMillis() ?
	panel->setLastTouchSecond (getTimeInSeconds(), fromStopAttract_);
	
	panel->clearTab (tabIndex_);
	// bug:78 - not currently needed
	//oscOutput->sendClearTab (panelIndex_, tabIndex_);
}


void SharedState::clearCurrentTab (int panelIndex_, bool fromStopAttract_)
{
   DBG (String(Time::currentTimeMillis()) + " "
        + "Clearing current tab on panel " + String(panelIndex_) + " from stopAttract " + String(fromStopAttract_));
	Panel* panel = panels[panelIndex_];
   clearTab(panelIndex_, panel->getTabIndex(), fromStopAttract_);
}

void SharedState::clearTab (int panelIndex_, int tabIndex_)
{
   clearTab(panelIndex_, tabIndex_, /* fromStopAttract */ false);
}

void SharedState::clearCurrentTab (int panelIndex_)
{
   clearCurrentTab(panelIndex_, /* fromStopAttract */ false);
}

// default is that we are *not* coming from stopAttract()

// Update and get the bit compressed serialized state of a panel
osc::Blob* SharedState::updateAndGetCompressedPanelState (int panelIndex_)
{
	unsigned char* values = (unsigned char*)(blobs[panelIndex_]->data);
	int numValues = blobs[panelIndex_]->size;
	
	for (int j = 0; j < Panel::kNumTabs; j++) {
		for (int k = 0; k < getTotalRows(); k++) {
			for (int l = 0; l < getTotalCols(); l++) {
				int n = j*getTotalRows()*getTotalCols() + k*getTotalCols() + l;
				int byte = n / (sizeof(unsigned char)*8);
				Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_, j, k, l);
				unsigned char isOn = (cell->isOn()) ? 1 : 0;
				values[byte] = (values[byte] << 1) | isOn;
			}
		}
	}
	for (int i = 0; i < paddingBits; i++) {
		values[numValues-1] <<= 1;
	}

	return blobs[panelIndex_];
}

// Get the serialized state of a panel, in the form of a String
String SharedState::getStringPanelState (int panelIndex_)
{
	int numTabs = Panel::kNumTabs;
	int numRows = getTotalRows();
	int numCols = getTotalCols();
	
	int numValues = numTabs * numRows * numCols;
	String valueString;
	
	// XXX if this is called frequently, it would be more efficient to
	// preallocate these arrays within the SharedState, and not once each time
	// this method is called
	valueString = String::empty;
	valueString.preallocateStorage (numValues);
	
	for (int j = 0; j < numTabs; j++) {
		for (int k = 0; k < numRows; k++) {
			for (int l = 0; l < numCols; l++) {
				Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_, j, k, l);
            // XXX what does it mean to shift a bool into a string?  is there some implicit casting going on here?
				valueString << cell->isOn();
			}
		}
	}	
	
	return valueString;	
}

// Set the state of a panel based on a serialized state string
void SharedState::setStringPanelState (int panelIndex_, String state)
{
	int numTabs = Panel::kNumTabs;
	int numRows = getTotalRows();
	int numCols = getTotalCols();
	
	int pos = 0;
	for (int j = 0; j < numTabs; j++) {
		for (int k = 0; k < numRows; k++) {
			for (int l = 0; l < numCols; l++) {
				bool isOn = (state[pos] == '1') ? true : false;
				Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_, j, k, l);
				if (isOn) {
					cell->setNoteOn();
				} else {
					cell->setNoteOff();
				}
				pos++;
			}
		}
	}		
}

// For touchOSC compatability
void SharedState::sendInefficientSync (int panelIndex_) {
	DBG (String(Time::currentTimeMillis()) + " "
        + "Sending inefficient sync to panel " + String(panelIndex_) + " for touchOSC compatability");
	
	// we don't bother tracking a touch osc controller disconnecting.  if one ever connects, we assume one is connected.
	touchOscConnected[panelIndex_] = true;
	
	// iterate similarly like we do in getStringPanelState() below,
	// but for all panels at once
	int numTabs = Panel::kNumTabs;
	int numRows = getTotalRows();
	int numCols = getTotalCols();
	
	for (int j = 0; j < numTabs; j++) {
		for (int k = 0; k < numRows; k++) {
			for (int l = 0; l < numCols; l++) {
				Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_,
																	/* tabIndex */ j,
																	/* row */ k,
																	/* col */ l);
				// XXX bug:79 - it would be nice to not broadcast this if not necessary
				// (but currently the constant OscOutput::kRemoteHost is used)
				oscOutput->sendNoteToggle(panelIndex_,
                                      /* tabIndex */ j,
                                      /* row */ k,
                                      /* col */ l,
                                      cell->isOn());
			}
		}
	}
}

// For touchOSC compatability
// Note that this does *not* actually clear any internal state.
// It just sends button off messages to all buttons that are on.
// Which means that it is imperative that this be called *before* the tab is actually cleared.
// An alternative would be to clear the tab and then send button off messages for everything,
// but that would be even more inefficient than necessary.
void SharedState::sendInefficientClearTab(int panelIndex_, int tabIndex_) {
	DBG (String(Time::currentTimeMillis()) + " "
        + "Sending inefficient clear tab for touchOSC compatability to panel="
        + String(panelIndex_) + " tab=" + String(tabIndex_));
	
	int numRows = getTotalRows();
	int numCols = getTotalCols();
	
	for (int k = 0; k < numRows; k++) {
		for (int l = 0; l < numCols; l++) {
			Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_,
																tabIndex_,
																/* row */ k,
																/* col */ l);
			// send note off for all notes that are currently on
			if (cell->isOn()) {
				// XXX bug:79 - it would be nice to not broadcast this if not necessary
				// (but currently the constant OscOutput::kRemoteHost is used)
				oscOutput->sendNoteToggle(panelIndex_,
                                      tabIndex_,
                                      /* row */ k,
                                      /* col */ l,
                                      /* isNoteOn */ false);
			}
		}
	}
}

void SharedState::updateStarField()
{
	for (int i = 0; i < kNumPanels; i++) {
		Panel* panel = panels[i];
		panel->updateStarField();
	}
}

bool SharedState::getStarFieldActive()
{
	return starFieldActive;
}

void SharedState::setStarFieldActive (bool starFieldActive_)
{
	starFieldActive = starFieldActive_;
}

void SharedState::enableStarField()
{
   // so that the button reflects the change in state done internally, without pressing the button
   // XXX bug:67 - this is a ToggleButton* in OptionsComponent -- how do i get a handle to it?
   // MainComponent has a pointer to OptionsComponent, but how do i get a handle to that?
   // for now commented out pending an answer from matt
   // although in practice this doesn't appear to be needed?  (i see the button checked)
   // mainComponent->optionsComponent->starFieldButton->setToggleState(/* shouldBeOn */ true,
   //                                                                  /* sendChangeNotification */ false);
   setStarFieldActive(true);
}

void SharedState::disableStarField()
{
   // XXX bug:67 - see same discussion above wrt ToggleButton* in OptionsComponent
   // mainComponent->optionsComponent->starFieldButton->setToggleState(/* shouldBeOn */ false,
   //                                                                  /* sendChangeNotification */ false);
   setStarFieldActive(false);
}

double SharedState::getLastTouchSecond (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	return panel->getLastTouchSecond();
}

int SharedState::getState (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	return panel->getState();
}

void SharedState::startDegrade (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	panel->startDegrade();
}

void SharedState::degradeStep (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	panel->degradeStep();
}

bool SharedState::allDegraded()
{
   for (int panelIndex = 0; panelIndex < kNumPanels; panelIndex++) {
      Panel* panel = panels[panelIndex];
      if (panel->getState() != Panel::DEGRADED) {
         return false;
      }
   }
   // we will only get here if all panels are in state DEGRADED
   return true;
}

void SharedState::startAttract()
{
   DBG(String(Time::currentTimeMillis()) + " "
       + "Starting attract mode");
   for (int panelIndex = 0; panelIndex < kNumPanels; panelIndex++) {
      Panel* panel = panels[panelIndex];
      panel->setState(Panel::ATTRACT);
   }
   enableStarField();
}

#ifdef JUCE_DEBUG
bool SharedState::allAttracting()
{
   for (int panelIndex = 0; panelIndex < kNumPanels; panelIndex++) {
      Panel* panel = panels[panelIndex];
      if (panel->getState() != Panel::ATTRACT) {
         return false;
      }
   }
   // we will only get here if all panels are in state ATTRACT
   return true;
}
#endif

void SharedState::stopAttract()
{
   DBG(String(Time::currentTimeMillis()) + " "
       + "Stopping attract mode");
   disableStarField();
   for (int panelIndex = 0; panelIndex < kNumPanels; panelIndex++) {
      // we don't need to explicitly reset the last touched time, b/c the following call will do that for us.
      // but we do need to specify that this is coming from stopAttract() so that we don't get stuck in an endless loop
      clearCurrentTab(panelIndex, /* fromStopAttract */ true);
      Panel* panel = panels[panelIndex];
      panel->setState(Panel::ACTIVE);
   }
}

