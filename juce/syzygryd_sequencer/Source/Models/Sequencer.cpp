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
playheadCol (0),
lastPlayheadCol (-1),
speed (4),
oscInput (0),
oscOutput (0)
{
	oscInput = new OscInput (this);
	oscOutput = new OscOutput (this);
	
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
	return playheadCol;
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
	 
	double playheadColPrecise = fmod (ppq * speed, totalCols);
	playheadCol = (int)playheadColPrecise;
	
	if (playheadCol != lastPlayheadCol) {

		lastPlayheadCol = playheadCol;
		
		double beatsPerSec = pos.bpm * speed / 60.0;
		double secPerBeat = 1.0 / beatsPerSec;	

		double playheadOffset = playheadColPrecise - playheadCol;
		int playheadOffsetSamples = playheadOffset * secPerBeat * sampleRate;
		playheadOffsetSamples = jmax (buffer.getNumSamples() - playheadOffsetSamples - 1, 0);
		
		for (int i = 0; i < totalRows; i++) {
			Cell* cell = getCellAt (i, playheadCol);
			int noteNumber = cell->getNoteNumber();
			if (noteNumber != -1) {
				MidiMessage m = MidiMessage::noteOn(1, noteNumber, 0.9f);
				midiMessages.addEvent (m, playheadOffsetSamples);
			}
		}
	}
}





