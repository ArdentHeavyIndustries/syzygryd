/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
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

#include "OscReceivedElements.h"
#include "OscPrintReceivedElements.h"

#include "JuceHeader.h"

class OscInput : public Thread
{
public:
	OscInput();
	~OscInput();
	
	// Thread methods
	virtual void run();

private:
	void clientConnect (osc::ReceivedMessage m);
	void noteToggle (osc::ReceivedMessage m);
	void clearTab (osc::ReceivedMessage m);
	void changeTab (osc::ReceivedMessage m);
   void OscInput::inefficientSync();
	
	DatagramSocket inSocket;
};

#endif
