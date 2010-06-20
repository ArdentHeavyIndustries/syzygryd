/*
 *  OscOutput.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "OscOutboundPacketStream.h"

#include "Sequencer.h"
#include "Cell.h"

#include "OscOutput.h"

const String kRemoteHost = "127.0.0.1";
const int kRemotePort = 9000;
const int kOutputBufferSize = 1024;
const int kTimeoutMs = 20;
const int kSleepInterval = 100;

OscOutput::OscOutput (Sequencer* sequencer_) :
Thread ("OscOutput"),
sequencer (sequencer_),
outSocket (0, true),
lastPlayheadCol (-1)
{
	outSocket.connect (kRemoteHost, kRemotePort, kTimeoutMs);
}

OscOutput::~OscOutput()
{
	outSocket.close();
}

// Thread methods
void OscOutput::run()
{
	while (! threadShouldExit()) {
		Thread::sleep (kSleepInterval);

		if (lastPlayheadCol == sequencer->getPlayheadCol()) {
			continue;
		}
		
		lastPlayheadCol = sequencer->getPlayheadCol();
		
		if (!outSocket.waitUntilReady (false, kTimeoutMs)) {
			continue;
		}
		char buffer[kOutputBufferSize];
		osc::OutboundPacketStream p( buffer, kOutputBufferSize );
		
		float tempo = ((float)sequencer->getPlayheadCol() + 1) / (float)sequencer->getTotalCols();
		
		p << osc::BeginMessage ("/1_tab1/tempo") << (float)tempo
		<< osc::EndMessage;
		
		outSocket.write (p.Data(), p.Size());
	}
}

