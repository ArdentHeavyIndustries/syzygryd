/*
 *  OscInput.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "OscReceivedElements.h"
#include "OscPrintReceivedElements.h"

#include "Sequencer.h"
#include "Cell.h"

#include "OscInput.h"

const int kLocalPort = 8000;
const int kTimeoutMs = 20;
const int kInputBufferSize = 1024;
const int kSleepInterval = 100;

OscInput::OscInput (Sequencer* sequencer_) :
Thread ("OscInput"),
sequencer (sequencer_),
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
		
		osc::ReceivedMessage m(p);
		String addressPattern (m.AddressPattern());
		if (addressPattern == "/server/connect") {
			DBG ("Client connected");
		} else if (addressPattern.contains("tab") &&
				   addressPattern.contains("panel")) {
			DBG (addressPattern)
			StringArray tokens;
			if (tokens.addTokens(addressPattern, String("/"), String::empty) == 0) {
				DBG ("No tokens found!")
				continue;
			}
			String tab = tokens[1];
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
			row = sequencer->getTotalRows() - row;
			col -= 1;
			
			String msg;
			msg << "Setting the status of cell " << row << ", " << col <<
			" to: " << status;
			DBG (msg) 
			
			// Update the sequencer
			Cell* cell = sequencer->getCellAt (row, col);
			if (status) {
				cell->setNoteOn();
			} else {
				cell->setNoteOff();
			}
		} else {
			DBG ("Unrecognized address pattern.")
		}
		
		// [/server/connect]
		// [/1_tab1/panel/6/9 float32:1]
		// [/1_tab1/panel/6/9 float32:0]
	}
}

