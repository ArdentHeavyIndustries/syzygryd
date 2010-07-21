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

static const int kNumPanels = 3;

juce_ImplementSingleton (SharedState)

SharedState::SharedState() :
totalRows (10),
totalCols (16),
oscInput (0),
oscOutput (0)
{
   blobs = new osc::Blob*[kNumPanels];
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
	}
	
	oscInput = new OscInput();
	oscOutput = new OscOutput();
	oscInput->startThread();
	oscOutput->startThread();	
}

SharedState::~SharedState()
{
	oscInput->stopThread(2000);
	oscOutput->stopThread(2000);
	delete oscInput;
	delete oscOutput;
   for (int i = 0; i < kNumPanels; i++) {
      free((unsigned char*) blobs[i]->data);
      delete blobs[i];
   }
   delete [] blobs;
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
	panel->setTabIndex (tabIndex_);
}

int SharedState::getPlayheadCol()
{
	return playheadCol;
}

void SharedState::setPlayheadCol (int playheadCol_)
{
	playheadCol = playheadCol_;
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
	Panel* panel = panels[panelIndex_];
	panel->clearTab (tabIndex_);
	oscOutput->sendClearTab (panelIndex_, tabIndex_);
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

void SharedState::setStringPanelState (int panelIndex_, String state)
{
	// Set the state of a panel based on a serialized state string
	int numTabs = 4;
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
