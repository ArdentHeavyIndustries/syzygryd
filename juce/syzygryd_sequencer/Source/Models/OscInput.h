/*
 *  OscInput.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/19/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef OscInput_H
#define OscInput_H

#include "JuceHeader.h"

class Sequencer;

class OscInput : public Thread
{
public:
	OscInput (Sequencer* sequencer_);
	~OscInput();
	
	// Thread methods
	virtual void run();

private:
	Sequencer* sequencer;
	
	DatagramSocket inSocket;
};

#endif
