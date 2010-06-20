/*
 *  OscOutput.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef OscOutput_H
#define OscOutput_H

#include "JuceHeader.h"

class Sequencer;

class OscOutput : public Thread
{
public:
	OscOutput (Sequencer* sequencer_);
	~OscOutput();
	
	// Thread methods
	virtual void run();
	
private:
	Sequencer* sequencer;
	
	DatagramSocket outSocket;
	
	int lastPlayheadCol;
};

#endif
