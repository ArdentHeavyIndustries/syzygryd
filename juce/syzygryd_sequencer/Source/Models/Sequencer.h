/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
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
class NoteOff {
public:
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
	double getPlayheadColPrecise();
	
	void noteToggle (int panelIndex_, int tabIndex_, 
					 int row_, int col_, bool isNoteOn);
	void clearTab (int panelIndex_, int tabIndex_);

	int getSwingTicks();
	void setSwingTicks (int swingTicks_);
	int getMaxSwingTicks();
	
	int getNoteLength();
	void setNoteLength (int noteLength_);
	int getMaxNoteLength();
	
	int getTicksPerCol();
	
	// AudioProcessorCallback methods
	virtual void prepareToPlay (double sampleRate_, int samplesPerBlock);
    virtual void releaseResources();
    virtual void processBlock (AudioSampleBuffer& buffer, 
							   MidiBuffer& midiMessages);	
	
private:
	PluginAudioProcessor* pluginAudioProcessor;
	
	// bug:51 - only one sequencer can be the primary one.  whichever asks first.
	bool primary;
	
	double sampleRate;
	
	int speed; // playback speed multiplier
	
	int ticksPerCol;   // how many internal ticks per column of notes
	int tickCount;     // how many total ticks counted
	int lastTickCount; // how many total ticks counted during the last processing event
	
	int swingTicks;    // how many ticks should odd columns be delayed
	
	OwnedArray<NoteOff> noteOffs; // all upcoming note-off events
	int noteLength;  // note length in ticks
	Array<bool> playingNotes; // which midi notes are currently playing
	
	double lastPlayheadColPrecise;

   bool columnZeroDegradeUpdate;	// to ensure that we only try to degrade once per tempo sweep
};

#endif
