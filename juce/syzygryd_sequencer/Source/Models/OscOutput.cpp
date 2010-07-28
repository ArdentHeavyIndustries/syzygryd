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
#include "Panel.h"

#include "OscOutput.h"

const String kRemoteHost = "255.255.255.255";
const int kRemotePort = 9000;
const int kOutputBufferSize = 1024;
const int kTimeoutMs = 20;

// we always send a tempo message once per column.  set this if we decide that
// it's too much traffic to send sync messages every column as well and we
// want to skip some.  we send a sync message every N columns if this is set
// to > 0.  e.g. 2 means every other column, 1 means every column.  set to 0
// to disable.  (so 1 is effectively the same as 0).
const int kSyncSkip = 0;

OscOutput::OscOutput () :
Thread ("OscOutput"),
outSocket (0, true),
lastPlayheadCol (-1),
sleepIntervalMs (125),
syncCount(0)
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
	
	DBG (msg);
	
	p << osc::BeginMessage (msg.toUTF8())
     << osc::EndMessage;
	outSocket.write (p.Data(), p.Size());		
}

void OscOutput::sendTempo()
{
	char buffer[kOutputBufferSize];
	osc::OutboundPacketStream p( buffer, kOutputBufferSize );
	
	int playheadCol = SharedState::getInstance()->getPlayheadCol();
	
	float tempo = (float)playheadCol / (float)SharedState::getInstance()->getTotalCols();
	
	p << osc::BeginMessage ("/1_tab1/tempo") << (float)tempo 
     << osc::EndMessage;
	outSocket.write (p.Data(), p.Size());	
}

void OscOutput::sendSync()
{
   syncCount++;
   if (kSyncSkip == 0 || syncCount >= kSyncSkip) {
      //DBG ("Sending sync: count=" + String(syncCount) + " skip=" + String(kSyncSkip));
      syncCount = 0;

      char buffer[kOutputBufferSize];
      osc::OutboundPacketStream p( buffer, kOutputBufferSize );

      double ppqPosition = SharedState::getInstance()->getPpqPosition();
      double timeInSeconds = SharedState::getInstance()->getTimeInSeconds();
      double bpm = SharedState::getInstance()->getBpm();
	
      int numPanels = SharedState::kNumPanels;
      int numTabs = Panel::kNumTabs;
      int numRows = SharedState::getInstance()->getTotalRows();
      int numCols = SharedState::getInstance()->getTotalCols();
	
      for (int panelIndex = 0; panelIndex < numPanels; panelIndex++) {
         int tabIndex = SharedState::getInstance()->getTabIndex (panelIndex);
         osc::Blob* blob = SharedState::getInstance()->updateAndGetCompressedPanelState (panelIndex);
		
         p.Clear();
         // XXX should there be the following in osc/OscOutboundPacketStream.cpp ?
         //        OutboundPacketStream& OutboundPacketStream::operator<<( unsigned int rhs )
         p << osc::BeginMessage ("/sync")
           << ppqPosition << timeInSeconds << bpm
           << panelIndex << tabIndex << numTabs << numRows << numCols
           << *blob
           << osc::EndMessage;
         outSocket.write (p.Data(), p.Size());
      }
   }	
   // else {
   //    DBG ("Skipping sync: count=" + String(syncCount) + " skip=" + String(kSyncSkip));
   // }
}

// Thread methods
void OscOutput::run()
{
	while (! threadShouldExit()) {
      // ms/col = ms/s / (col/beat * beat/min / s/min)
      sleepIntervalMs = (int)(1000.0 / ((4.0 * SharedState::getInstance()->getBpm()) / 60.0));
      //DBG ("Sleeping for " + String(sleepIntervalMs) + " ms");
		Thread::sleep (sleepIntervalMs);

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
