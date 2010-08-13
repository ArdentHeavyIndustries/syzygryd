/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  OscInput.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */


#include "Cell.h"
#include "SharedState.h"

#include "OscInput.h"

const int kLocalPort = 8000;
const int kTimeoutMs = 20;
const int kInputBufferSize = 1024;
const int kSleepInterval = 100;

OscInput::OscInput () :
Thread ("OscInput"),
inSocket (kLocalPort, false)
{
	startThread();
	
}

OscInput::~OscInput()
{
	stopThread (4000);
	inSocket.close();
}

// Thread methods
void OscInput::run()
{
	while (! threadShouldExit()) {
		Thread::sleep (kSleepInterval);

		if (!inSocket.waitUntilReady (true, kTimeoutMs)) {
			continue;
		}
		
		char buffer[kInputBufferSize];
		int bytesRead = 0;
		if (!(bytesRead = inSocket.read (buffer, kInputBufferSize, false))) {
			continue;
		}
		
		osc::ReceivedPacket p(buffer, bytesRead);
		if (!p.IsMessage()) {
			continue;
		}
		std::cout << p;
		SharedState::getInstance()->broadcast (buffer, bytesRead);
		
		osc::ReceivedMessage m(p);
		String addressPattern (m.AddressPattern());
		if (addressPattern == "/server/connect") {
			clientConnect (m);
		} else if (addressPattern.contains("tab") &&
                 addressPattern.contains("panel")) {
			noteToggle (m);
		} else if (addressPattern.contains("control") &&
                 addressPattern.contains("clear")) { 
			clearTab (m);
		} else if (addressPattern.contains("tab")) {
			changeTab (m);
      } else if (addressPattern.contains("_control/syncRequest")) {
         inefficientSync (m);
		} else {
			DBG ("Unrecognized address pattern.")
		}
	}
}

void OscInput::clientConnect (osc::ReceivedMessage m)
{
	// Client connected
	// [/server/connect]
	DBG ("Client connected");
}

void OscInput::noteToggle (osc::ReceivedMessage m)
{
	// Turning on and off notes
	// [/1_tab1/panel/6/9 float32:1]
	// [/1_tab1/panel/6/9 float32:0]	
	String addressPattern (m.AddressPattern());
	DBG (addressPattern)
	StringArray tokens;
	if (tokens.addTokens(addressPattern, String("/"), String::empty) == 0) {
		DBG ("No tokens found!")
		return;
	}
	// Parse panel and tab
	String tab = tokens[1];
	StringArray tabTokens;
	if (tabTokens.addTokens(tab, String("_tab"), String::empty) == 0) {
		DBG ("No tab tokens found!")
		return;
	}
	int panelIndex = tabTokens[0].getIntValue();
	int tabIndex = tabTokens[4].getIntValue();
	
	String panel = tokens[2];
	int row = String(tokens[3]).getIntValue();
	int col = String(tokens[4]).getIntValue();
	
	bool status;
	try {
		osc::ReceivedMessage::const_iterator arg_i = m.ArgumentsBegin();
		
		status = (bool)((arg_i++)->AsFloat());
		
		if (arg_i != m.ArgumentsEnd()) {
			throw osc::ExcessArgumentException();
		}
	} catch (osc::Exception& e) {
		std::cout << "error while parsing message: "
		<< m.AddressPattern() << ": " << e.what() << "\n";
	}
	
	// Adjust XY Coordinate system
	row = SharedState::getInstance()->getTotalRows() - row;
	col -= 1;
	
	DBG ("Setting the status of cell " + String(row) + ", " + String(col) +
        " on tab " + String(tabIndex) + " panel " + String(panelIndex) + " to: " + String(status));
	
	// Update the shared sequencer state
	Cell* cell = SharedState::getInstance()->getCellAt (panelIndex - 1, 
														tabIndex - 1, 
														row, col);
	if (status) {
		cell->setNoteOn();
	} else {
		cell->setNoteOff();
	}	
}

void OscInput::clearTab (osc::ReceivedMessage m)
{
	// Clearing a tab
	//[/1_control/clear/tab1]
	String addressPattern (m.AddressPattern());
	DBG (addressPattern)
	StringArray tokens;
	if (tokens.addTokens(addressPattern, String("/"), String::empty) == 0) {
		DBG ("No tokens found!")
		return;
	}
	// Parse panel
	String control = tokens[1];
	StringArray controlTokens;
	if (controlTokens.addTokens(control, String("_control"), String::empty) == 0) {
		DBG ("No control tokens found!")
		return;
	}
	int panelIndex = controlTokens[0].getIntValue() - 1;
	// Parse tab
	String tab = tokens[3];
	StringArray tabTokens;
	if (tabTokens.addTokens(tab, String("tab"), String::empty) == 0) {
		DBG ("No tab tokens found!")
		return;
	}
	int tabIndex = tabTokens[3].getIntValue() - 1;
	
	DBG ("Clearing tab " + String(tabIndex) + " on panel " + String(panelIndex));
   // bug:72 also need to send inefficiently for touchosc
	SharedState::getInstance()->clearTab (panelIndex, tabIndex);	
}

void OscInput::changeTab (osc::ReceivedMessage m)
{
	// Changing tabs
	// [/1_tab2]    
	String addressPattern (m.AddressPattern());
	DBG (addressPattern)
	StringArray tokens;
	if (tokens.addTokens(addressPattern, String("/"), String::empty) == 0) {
		DBG ("No tokens found!")
		return;
	}
	// Parse panel and tab
	String tab = tokens[1];
	StringArray tabTokens;
	if (tabTokens.addTokens(tab, String("_tab"), String::empty) == 0) {
		DBG ("No tab tokens found!")
		return;
	}
	int panelIndex = tabTokens[0].getIntValue() - 1;
	int tabIndex = tabTokens[4].getIntValue() - 1;
	
	DBG ("Setting current tab to " + String(tabIndex)
        + " on panel " + String(panelIndex));
	
	SharedState::getInstance()->setTabIndex (panelIndex, tabIndex);			
}

void OscInput::inefficientSync (osc::ReceivedMessage m) {
   // [/1_control/syncRequest]
   // assume that this means that some touchOsc controller is connected,
   // which will be needed for the inefficient clear tab

   // Parse panel
   // XXX this is somewhat fragile, because it assumes that the number of panels only takes up a single digit
   // but that's true for now, and generalizing it further wouldn't be too hard
   jassert(SharedState::kNumPanels < 10);
	String addressPattern (m.AddressPattern());
	DBG (addressPattern);
   int panelIndex = addressPattern.substring(1,2).getIntValue() - 1;
   jassert(panelIndex >= 0 && panelIndex < SharedState::kNumPanels);

   DBG ("Sending inefficient sync to panel " + String(panelIndex));
   SharedState::getInstance()->sendInefficientSync (panelIndex);
}
