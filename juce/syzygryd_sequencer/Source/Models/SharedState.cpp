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

#include "SharedState.h"

static const int kNumPanels = 3;

juce_ImplementSingleton (SharedState)

SharedState::SharedState() :
totalRows (10),
totalCols (16),
oscInput (0),
oscOutput (0)
{
	for (int i = 0; i < kNumPanels; i++) {
		Panel* panel = new Panel (totalRows, totalCols);
		panels.add (panel);
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

String SharedState::getPanelState (int panelIndex_)
{
	// Get the serialized state of a panel
	int numTabs = 4;
	int numRows = getTotalRows();
	int numCols = getTotalCols();
	
	int numValues = numTabs * numRows * numCols;
	String valueString;
	
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

void SharedState::setPanelState (int panelIndex_, String state)
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









