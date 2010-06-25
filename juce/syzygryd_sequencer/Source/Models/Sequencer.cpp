/*
 *  Sequencer.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/16/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "OscInput.h"
#include "OscOutput.h"

#include "Sequencer.h"

Sequencer::Sequencer (PluginAudioProcessor* pluginAudioProcessor_) :
AudioProcessorCallback (pluginAudioProcessor),
pluginAudioProcessor (pluginAudioProcessor_),
totalRows (10),
totalCols (16),
speed (4),
oscInput (0),
oscOutput (0),
ticksPerCol (4),
tickCount (0),
lastTickCount (-1),
swingEnabled (false),
swingTicks (1),
dynamicsEnabled (false)
{
	oscInput = new OscInput (this);
	oscOutput = new OscOutput (this);
	
	// Initialize the cells
	for (int i = 0; i < totalRows; i++) {
		OwnedArray<Cell>* row;
		rows.add(row = new OwnedArray<Cell>);
		
		for (int j = 0; j < totalCols; j++) {
			Cell* cell;
			row->add (cell = new Cell (i, j));
			if (i != 0) {
				Cell* northCell = rows.getUnchecked (i - 1)->getUnchecked(j);
				cell->setNorthCell (northCell);
				northCell->setSouthCell (cell);
			}
			if (j != 0) {
				Cell* westCell = row->getUnchecked(j - 1);
				cell->setWestCell (westCell);
				westCell->setEastCell (cell);
			}
		}
	}
	
	oscInput->startThread();
	oscOutput->startThread();
}

Sequencer::~Sequencer()
{
	oscInput->stopThread(2000);
	oscOutput->stopThread(2000);
	delete oscInput;
	delete oscOutput;
}

int Sequencer::getTotalRows()
{
	return totalRows;
}

int Sequencer::getTotalCols()
{
	return totalCols;
}

Cell* Sequencer::getCellAt (int row_, int col_)
{
	OwnedArray<Cell>* row = rows[row_];
	Cell* cell = row->getUnchecked (col_);
	return cell;
}

int Sequencer::getPlayheadCol()
{
	return tickCount / ticksPerCol;
}

bool Sequencer::getSwingEnabled()
{
	return swingEnabled;
}

void Sequencer::setSwingEnabled (bool swingEnabled_)
{
	swingEnabled = swingEnabled_;
}

bool Sequencer::getDynamicsEnabled()
{
	return dynamicsEnabled;
}

void Sequencer::setDynamicsEnabled (bool dynamicsEnabled_)
{
	dynamicsEnabled = dynamicsEnabled_;
}

// AudioProcessorCallback methods
void Sequencer::prepareToPlay (double sampleRate_, int samplesPerBlock)
{
	sampleRate = sampleRate_;
}

void Sequencer::releaseResources()
{
}

void Sequencer::processBlock (AudioSampleBuffer& buffer,
							  MidiBuffer& midiMessages)
{
	AudioPlayHead::CurrentPositionInfo pos (pluginAudioProcessor->lastPosInfo);	

	if (! pos.isPlaying) {
		return;
	}
	
	double ppq = pos.ppqPosition;

	/*
	int numerator = pos.timeSigNumerator;
	int denominator = pos.timeSigDenominator;
	
	const int ppqPerBar = (numerator * 4 / denominator); // e.g. 4 if 4/4
	const double beats = (fmod (ppq, ppqPerBar) / ppqPerBar) * numerator;
	
	const int bar = ((int) ppq) / ppqPerBar + 1;
	const int beat = ((int) beats) + 1;
	const int ticks = ((int) (fmod (beats, 1.0) * 960.0));	
	*/
	
	
	
	double tickCountPrecise = fmod (ppq * speed * ticksPerCol, totalCols * ticksPerCol);
	tickCount = (int)tickCountPrecise;
	
	if (tickCount != lastTickCount) {

		lastTickCount = tickCount;
		
		bool playCol = false;  // play the current column of notes?
		float velocity = 0.9f;		
		
		// Unswung
		if (!swingEnabled) {
			// If we're on the first tick of the column
			if (tickCount % ticksPerCol == 0) {
				playCol = true;
			}
		}
		
		// Swung
		if (swingEnabled) {
			// If we're on an odd column
			if (getPlayheadCol() % 2 != 0) {
				// If we've waiting enough ticks for the swing
				if (tickCount == (getPlayheadCol() * ticksPerCol) + swingTicks) {
					playCol = true;
				}
			} else {
				// Else we're on an even column
				// If we're on the first tick of the column...
				if (tickCount % ticksPerCol == 0) {
					playCol = true;
				}
			}
		}
		
		if (dynamicsEnabled) {
			// If we're on an odd column
			if (getPlayheadCol() % 2 != 0) {
				velocity = 0.8f;
			}
		}
		
		// If we should play the current column of notes
		if (playCol) {
			double beatsPerSec = pos.bpm * speed * ticksPerCol / 60.0;
			double secPerBeat = 1.0 / beatsPerSec;	
			
			double tickOffset = tickCountPrecise - tickCount;
			int tickOffsetSamples = tickOffset * secPerBeat * sampleRate;
			tickOffsetSamples = jmax (buffer.getNumSamples() - tickOffsetSamples - 1, 0);
			
			for (int i = 0; i < totalRows; i++) {
				Cell* cell = getCellAt (i, getPlayheadCol());
				int noteNumber = cell->getNoteNumber();
				if (noteNumber != -1) {
					MidiMessage m = MidiMessage::noteOn(1, noteNumber, velocity);
					midiMessages.addEvent (m, tickOffsetSamples);
					MidiMessage m2 = MidiMessage::noteOff(1, noteNumber);
					midiMessages.addEvent (m2, tickOffsetSamples);
				}
			}
		}
	}
	
}





