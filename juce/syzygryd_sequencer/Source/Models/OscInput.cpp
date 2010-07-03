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
}

OscInput::~OscInput()
{
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
		SharedState::getInstance()->broadcast (buffer, bytesRead); // for safety
		
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
	
	String msg;
	msg << "Setting the status of cell " << row << ", " << col <<
	" on tab " << tabIndex << " panel " << panelIndex << " to: " << status;
	DBG (msg) 
	
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
	
	String msg;
	msg << "Clearing tab " << tabIndex << " on panel " << panelIndex;
	DBG (msg)
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
	
	String msg;
	msg << "Setting current tab to " << tabIndex 
	<< " on panel " << panelIndex;
	DBG (msg)
	
	SharedState::getInstance()->setTabIndex (panelIndex, tabIndex);			
}





