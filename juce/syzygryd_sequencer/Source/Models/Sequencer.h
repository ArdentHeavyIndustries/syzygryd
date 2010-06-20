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

class Cell;
class OscInput;
class OscOutput;

class Sequencer : public AudioProcessorCallback
{
public:
	Sequencer (PluginAudioProcessor* pluginAudioProcessor_);
	~Sequencer();
	
	int getTotalRows();
	int getTotalCols();
	Cell* getCellAt (int row, int col);
	int getPlayheadCol();

	// AudioProcessorCallback methods
	virtual void prepareToPlay (double sampleRate_, int samplesPerBlock);
    virtual void releaseResources();
    virtual void processBlock (AudioSampleBuffer& buffer, 
							   MidiBuffer& midiMessages);	
	
private:
	PluginAudioProcessor* pluginAudioProcessor;
	OscInput* oscInput;
	OscOutput* oscOutput;
	
	double sampleRate;
	
	const int totalRows;
	const int totalCols;
	OwnedArray< OwnedArray<Cell> > rows;

	int playheadCol;
	int lastPlayheadCol;
	
	int speed; // playback speed multiplier
};

#endif
