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

class OscOutput : public Thread
{
public:
	OscOutput();
	~OscOutput();
	
	void broadcast (const void* sourceBuffer, int numBytesToWrite);
	void sendNoteToggle (int panelIndex, int tabIndex, int row, int col, 
						 bool isNoteOn);
	void sendClearTab (int panelIndex, int tabIndex);
	
	// Thread methods
	virtual void run();
	
private:
	DatagramSocket outSocket;
	
	int lastPlayheadCol;
};

#endif
