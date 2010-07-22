/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  Sequencer.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/16/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "Panel.h"
#include "SharedState.h"
#include "PluginAudioProcessor.h"

#include "Sequencer.h"

Sequencer::Sequencer (PluginAudioProcessor* pluginAudioProcessor_) :
AudioProcessorCallback (pluginAudioProcessor_),
pluginAudioProcessor (pluginAudioProcessor_),
speed (4),
ticksPerCol (8),
tickCount (0),
lastTickCount (-1),
swingTicks (2),
noteLength (4)
{
}

Sequencer::~Sequencer()
{
}

int Sequencer::getTotalRows()
{
	return SharedState::getInstance()->getTotalRows();
}

int Sequencer::getTotalCols()
{
	return SharedState::getInstance()->getTotalCols();
}

Cell* Sequencer::getCellAt (int panelIndex_, int tabIndex_, int row_, int col_)
{
	return SharedState::getInstance()->getCellAt (panelIndex_, tabIndex_, row_, col_);
}

void Sequencer::noteToggle (int panelIndex_, int tabIndex_,
							int row_, int col_, bool isNoteOn)
{
	SharedState::getInstance()->noteToggle (panelIndex_, tabIndex_,
											row_, col_, isNoteOn);
}

void Sequencer::clearTab (int panelIndex_, int tabIndex_)
{
	SharedState::getInstance()->clearTab (panelIndex_, tabIndex_);
}

int Sequencer::getPlayheadCol()
{
	int playheadCol = tickCount / ticksPerCol;
	SharedState::getInstance()->setPlayheadCol (playheadCol);
	return playheadCol;
}

int Sequencer::getSwingTicks()
{
	return swingTicks;
}

void Sequencer::setSwingTicks (int swingTicks_)
{
	swingTicks = swingTicks_;
}

int Sequencer::getMaxSwingTicks()
{
	return getTicksPerCol() - 1;
}

int Sequencer::getNoteLength()
{
	return noteLength;
}

void Sequencer::setNoteLength (int noteLength_)
{
	noteLength = noteLength_;
}

int Sequencer::getMaxNoteLength()
{
	return 20;
}

int Sequencer::getTicksPerCol()
{
	return ticksPerCol;
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
   SharedState::getInstance()->setPpqPosition (ppq);

   double timeInSeconds = pos.timeInSeconds;
   SharedState::getInstance()->setTimeInSeconds (timeInSeconds);

   double bpm = pos.bpm;
   SharedState::getInstance()->setBpm (bpm);

	/*
	int numerator = pos.timeSigNumerator;
	int denominator = pos.timeSigDenominator;
	
	const int ppqPerBar = (numerator * 4 / denominator); // e.g. 4 if 4/4
	const double beats = (fmod (ppq, ppqPerBar) / ppqPerBar) * numerator;
	
	const int bar = ((int) ppq) / ppqPerBar + 1;
	const int beat = ((int) beats) + 1;
	const int ticks = ((int) (fmod (beats, 1.0) * 960.0));	
	*/
	
	double tickCountPrecise = fmod (ppq * speed * ticksPerCol, getTotalCols() * ticksPerCol);
	tickCount = (int)tickCountPrecise;
	
	if (tickCount != lastTickCount) {

		lastTickCount = tickCount;
		
		bool playCol = false;  // play the current column of notes?
		float velocity = 0.9f;		
		
		// Swing...
		// If we're on an odd column
		if (getPlayheadCol() % 2 != 0) {
			// If we've waited for enough ticks for the swing
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
		
		// Calculate the latency
		double beatsPerSec = bpm * speed * ticksPerCol / 60.0;
		double secPerBeat = 1.0 / beatsPerSec;	
		
		double tickOffset = tickCountPrecise - tickCount;
		int tickOffsetSamples = tickOffset * secPerBeat * sampleRate;
		tickOffsetSamples = jmax (buffer.getNumSamples() - tickOffsetSamples - 1, 0);
		
		// If we should play the current column of notes
		if (playCol) {
			int panelIndex = pluginAudioProcessor->getPanelIndex();
			int tabIndex = pluginAudioProcessor->getTabIndex();

			for (int i = 0; i < getTotalRows(); i++) {
				Cell* cell = getCellAt (panelIndex, tabIndex, i, getPlayheadCol());
				int noteNumber = cell->getNoteNumber();
				if (noteNumber != -1) {
					MidiMessage m = MidiMessage::noteOn (1, noteNumber, velocity);
					midiMessages.addEvent (m, tickOffsetSamples);
					// Add an upcoming note-off event
					noteOff no;
					no.tick = tickCount + noteLength;
					no.noteNumber = noteNumber;
					noteOffs.add (no);
				}
			}
		}
		
		// Send any upcoming note-off events
		Array<int> notesToRemove; 
		for (int i = 0; i < noteOffs.size(); i++) {
			if (noteOffs[i].tick <= tickCount) {
				MidiMessage m2 = MidiMessage::noteOff(1, noteOffs[i].noteNumber);
				midiMessages.addEvent (m2, tickOffsetSamples);			
				notesToRemove.add (i);
			}
		}
		for (int i = 0; i < notesToRemove.size(); i++) {
			// Remove the event from the note-off event list
			// (We do this in two steps so that the noteOffs array isn't modified inside a loop)
			noteOffs.remove (notesToRemove[i]);
		}
	}
}
