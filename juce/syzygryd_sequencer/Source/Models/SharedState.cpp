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
const int SharedState::kDegradeTimeInSeconds = 2.5;

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
   int paddingBits = numValues - numBits;
   if (paddingBits > 0) {
      numBytes++;
   }

	for (int i = 0; i < kNumPanels; i++) {
		Panel* panel = new Panel (totalRows, totalCols);
		panels.add (panel);

      blobs[i] = new osc::Blob();
      unsigned char* values = (unsigned char*)calloc(numBytes, sizeof(unsigned char));
      blobs[i]->data = (void*) values;
      blobs[i]->size = numBytes * sizeof(unsigned char);

      touchOscConnected[i] = false;
	}

	oscInput = new OscInput();
	oscOutput = new OscOutput();
	oscInput->startThread();
	oscOutput->startThread();	
}

SharedState::~SharedState()
{
	oscInput->stopThread(4000);
	oscOutput->stopThread(4000);
	delete oscInput;
	delete oscOutput;
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
	Panel* panel = panels[panelIndex_];
	panel->setLastTouchSecond (getTimeInSeconds());

	panel->setTabIndex (tabIndex_);
}

int SharedState::getPlayheadCol()
{
	return (int)getPlayheadColPrecise();
}

double SharedState::getPlayheadColPrecise()
{
	return playheadColPrecise;
}

void SharedState::setPlayheadColPrecise (int playheadColPrecise_)
{
	playheadColPrecise = playheadColPrecise_;
}

double SharedState::getPpqPosition()
{
	return ppqPosition;
}

void SharedState::setPpqPosition (double ppqPosition_)
{
	ppqPosition = ppqPosition_;
}

double SharedState::getTimeInSeconds()
{
	return timeInSeconds;
}

void SharedState::setTimeInSeconds (double timeInSeconds_)
{
	timeInSeconds = timeInSeconds_;
}

double SharedState::getBpm()
{
	return bpm;
}

void SharedState::setBpm (double bpm_)
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
	Panel* panel = panels[panelIndex_];
	panel->setLastTouchSecond (getTimeInSeconds());
	
	Cell* cell = getCellAt (panelIndex_, tabIndex_, row_, col_);
	if (state) {
		cell->setNoteOn();
	} else {
		cell->setNoteOff();
	}
	oscOutput->sendNoteToggle (panelIndex_, tabIndex_, row_, col_, state);
}

void SharedState::clearTab (int panelIndex_, int tabIndex_)
{
   // Send inefficient clear to touchOSC controllers.
   // This must be done *before* the actual clear.
   // Only do if needed.
   // XXX bug:79 - not broadcasting would be better
   if (touchOscConnected[panelIndex_]) {
      sendInefficientClearTab (panelIndex_, tabIndex_);
   }
   //#ifdef JUCE_DEBUG
   else {
      DBG ("Not sending inefficient clear tab for touchOSC compatability to panel="
           + String(panelIndex_) + " tab=" + String(tabIndex_)
           + " because no touchOSC controller has connected yet");
   }
   //#endif
	Panel* panel = panels[panelIndex_];
	panel->setLastTouchSecond (getTimeInSeconds());
	
	panel->clearTab (tabIndex_);
   // bug:78 - not currently needed
	//oscOutput->sendClearTab (panelIndex_, tabIndex_);
}

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
				unsigned char isOn = (cell->getNoteNumber() > 0) ? 1 : 0;
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
				bool isOn = (cell->getNoteNumber() > 0) ? 1 : 0;
				valueString << isOn;
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
   DBG ("Sending inefficient sync to panel " + String(panelIndex_) + " for touchOSC compatability");

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
            bool isOn = (cell->getNoteNumber() > 0) ? 1 : 0;
            // XXX bug:79 - it would be nice to not broadcast this if not necessary
            // (but currently the constant OscOutput::kRemoteHost is used)
            oscOutput->sendNoteToggle(panelIndex_,
                                      /* tabIndex */ j,
                                      /* row */ k,
                                      /* col */ l,
                                      isOn);
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
   DBG ("Sending inefficient clear tab for touchOSC compatability to panel="
        + String(panelIndex_) + " tab=" + String(tabIndex_));

	int numRows = getTotalRows();
	int numCols = getTotalCols();

   for (int k = 0; k < numRows; k++) {
      for (int l = 0; l < numCols; l++) {
         Cell *cell = SharedState::getInstance()->getCellAt (panelIndex_,
                                                             tabIndex_,
                                                             /* row */ k,
                                                             /* col */ l);
         bool isOn = (cell->getNoteNumber() > 0) ? 1 : 0;
         // send note off for all notes that are currently on
         if (isOn) {
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

void SharedState::update()
{
	for (int i = 0; i < kNumPanels; i++) {
		Panel* panel = panels[i];
		panel->update();
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

double SharedState::getLastTouchSecond (int panelIndex_)
{
	Panel* panel = panels[panelIndex_];
	return panel->getLastTouchSecond();
}
