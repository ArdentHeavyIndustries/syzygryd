/*
 *  Sequencer.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/16/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef Sequencer_H
#define Sequencer_H

#include "PluginAudioProcessor.h"
#include "AudioProcessorCallback.h"

#include "JuceHeader.h"

// Holds data for an upcoming note-off event
struct noteOff {
	int noteNumber;
	int tick;
};

class Cell;
class Panel;

class Sequencer : AudioProcessorCallback
{
public:
	Sequencer (PluginAudioProcessor* pluginAudioProcessor_);
	~Sequencer();
	
	int getTotalRows();
	int getTotalCols();
	Cell* getCellAt (int panelIndex_, int tabIndex_, int row_, int col_);
	int getPlayheadCol();

	void noteToggle (int panelIndex_, int tabIndex_, 
					 int row_, int col_, bool isNoteOn);
	void clearTab (int panelIndex_, int tabIndex_);
	
	bool getSwingEnabled();
	void setSwingEnabled (bool swingEnabled_);
	bool getDynamicsEnabled();
	void setDynamicsEnabled (bool dynamicsEnabled_);
	
	int getNoteLength();
	void setNoteLength (int noteLength_);
	
	int getTicksPerCol();
	
	// AudioProcessorCallback methods
	virtual void prepareToPlay (double sampleRate_, int samplesPerBlock);
    virtual void releaseResources();
    virtual void processBlock (AudioSampleBuffer& buffer, 
							   MidiBuffer& midiMessages);	
	
private:
	PluginAudioProcessor* pluginAudioProcessor;

	double sampleRate;

	int speed; // playback speed multiplier

	int ticksPerCol;   // how many internal ticks per column of notes
	int tickCount;     // how many total ticks counted
	int lastTickCount; // how many total ticks counted during the last processing event
	bool swingEnabled; // is swing enabled
	int swingTicks;    // how many ticks should odd columns be delayed
	
	bool dynamicsEnabled; // reduce the velocity of odd columned notes
	
	Array<noteOff> noteOffs; // all upcoming note-off events
	int noteLength;  // note length in ticks
};

#endif
