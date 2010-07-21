/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  OscOutput.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "OscOutboundPacketStream.h"

#include "Cell.h"
#include "SharedState.h"

#include "OscOutput.h"

const String kRemoteHost = "255.255.255.255";
const int kRemotePort = 9000;
const int kOutputBufferSize = 1024;
const int kTimeoutMs = 20;
const int kSleepInterval = 100;

OscOutput::OscOutput () :
Thread ("OscOutput"),
outSocket (0, true),
lastPlayheadCol (-1)
{
	outSocket.connect (kRemoteHost, kRemotePort, kTimeoutMs);
}

OscOutput::~OscOutput()
{
	outSocket.close();
}

void OscOutput::broadcast (const void* sourceBuffer, int numBytesToWrite)
{
	outSocket.write (sourceBuffer, numBytesToWrite);
}

void OscOutput::sendNoteToggle (int panelIndex, int tabIndex, int row, int col,
								bool isNoteOn)
{
	char buffer[kOutputBufferSize];
	osc::OutboundPacketStream p( buffer, kOutputBufferSize );
	
	// Adjust XY Coordinate system
	row = SharedState::getInstance()->getTotalRows() - row;
	col++;
	panelIndex++;
	tabIndex++;
	
	// [/1_tab1/panel/6/9 float32:1]
	String msg;
	msg << "/" << panelIndex << "_tab" << tabIndex << "/panel/" << row 
       << "/" << col;
	
	float state = 0;
	if (isNoteOn) state = 1.0;
	
	p << osc::BeginMessage (msg.toUTF8()) << state
     << osc::EndMessage;
	outSocket.write (p.Data(), p.Size());	
}

void OscOutput::sendClearTab (int panelIndex, int tabIndex)
{
	char buffer[kOutputBufferSize];
	osc::OutboundPacketStream p( buffer, kOutputBufferSize );
	
	panelIndex++;
	tabIndex++;

	//[/1_control/clear/tab1]
	String msg;
	msg << "/" << panelIndex << "_control/clear/tab" << tabIndex;
	
	DBG (msg)
	
	p << osc::BeginMessage (msg.toUTF8())
	<< osc::EndMessage;
	outSocket.write (p.Data(), p.Size());		
}

void OscOutput::sendTempo()
{
	char buffer[kOutputBufferSize];
	osc::OutboundPacketStream p( buffer, kOutputBufferSize );
	
	int playheadCol = SharedState::getInstance()->getPlayheadCol();
	
	float tempo = ((float)playheadCol + 1) / (float)SharedState::getInstance()->getTotalCols();
	
	p << osc::BeginMessage ("/1_tab1/tempo") << (float)tempo 
     << osc::EndMessage;
	outSocket.write (p.Data(), p.Size());	
}

void OscOutput::sendSync()
{
	char buffer[kOutputBufferSize];
	osc::OutboundPacketStream p( buffer, kOutputBufferSize );
	
	int numPanels = 3;
	
	int numTabs = 4;
	int numRows = SharedState::getInstance()->getTotalRows();
	int numCols = SharedState::getInstance()->getTotalCols();
	
	for (int panelIndex = 0; panelIndex < numPanels; panelIndex++) {
		int tabIndex = SharedState::getInstance()->getTabIndex (panelIndex);
      osc::Blob* blob = SharedState::getInstance()->updateAndGetCompressedPanelState (panelIndex);
		
		p.Clear();
      // XXX should there be the following in osc/OscOutboundPacketStream.cpp ?
      //        OutboundPacketStream& OutboundPacketStream::operator<<( unsigned int rhs )
		p << osc::BeginMessage ("/sync") 
        << panelIndex << tabIndex << numTabs << numRows << numCols
        << (int)blob->size << *blob
        << osc::EndMessage;
		outSocket.write (p.Data(), p.Size());
	}	
}

// Thread methods
void OscOutput::run()
{
	while (! threadShouldExit()) {
		Thread::sleep (kSleepInterval);

		int playheadCol = SharedState::getInstance()->getPlayheadCol();
		
		if (lastPlayheadCol == playheadCol) {
			continue;
		}
		
		lastPlayheadCol = playheadCol;
		
		if (!outSocket.waitUntilReady (false, kTimeoutMs)) {
			continue;
		}

		sendTempo();
		sendSync();
	}
}
