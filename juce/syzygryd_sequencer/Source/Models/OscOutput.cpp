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
		char buffer[kOutputBufferSize];
		osc::OutboundPacketStream p( buffer, kOutputBufferSize );
		
		float tempo = ((float)playheadCol + 1) / (float)SharedState::getInstance()->getTotalCols();
		
		p << osc::BeginMessage ("/1_tab1/tempo") << (float)tempo
		<< osc::EndMessage;
		outSocket.write (p.Data(), p.Size());
	}
}

