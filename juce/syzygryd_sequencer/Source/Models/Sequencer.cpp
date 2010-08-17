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
noteLength (4),
lastPlayheadColPrecise (0),
columnZeroDegradeUpdate (false)
{
	primary = SharedState::getInstance()->testAndSetPrimarySequencer();
	DBG ("Sequencer " + String(pluginAudioProcessor->getPanelIndex()) + (primary ? " IS" : " is NOT") + " the primary");
	
	for (int i = 0; i < 128; i++) {
		playingNotes.add (false);
	}
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
	//int playheadCol = tickCount / ticksPerCol;
	int playheadCol = (int)lastPlayheadColPrecise;
	return playheadCol;
}

double Sequencer::getPlayheadColPrecise()
{
	return lastPlayheadColPrecise;
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
	noteLength = jmax(noteLength_, 1);
}

int Sequencer::getMaxNoteLength()
{
	return getTicksPerCol() * 15;
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
	
	// If we aren't playing...
	if (! pos.isPlaying) {
		if (noteOffs.size() > 0) {
			// Send any upcoming note-off events
			Array<NoteOff*> notesToRemove; 
			for (int i = 0; i < noteOffs.size(); i++) {
				int noteNumber = noteOffs[i]->noteNumber;
				MidiMessage m2 = MidiMessage::noteOff (1, noteNumber);
				midiMessages.addEvent (m2, 0);			
				playingNotes.set (noteNumber, false);

				notesToRemove.add (noteOffs[i]);
			}
			for (int i = 0; i < notesToRemove.size(); i++) {
				// Remove the event from the note-off event list
				// (We do this in two steps so that the noteOffs array isn't modified inside a loop)
				noteOffs.removeObject (notesToRemove[i], true);
			}			
		}
		return;
	}
	
	double ppq = pos.ppqPosition;
	double timeInSeconds = pos.timeInSeconds;
	double bpm = pos.bpm;
	//if (primary) {
		SharedState::getInstance()->setPpqPosition (ppq);
		SharedState::getInstance()->setTimeInSeconds (timeInSeconds);
		SharedState::getInstance()->setBpm (bpm);
	//}
	
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
	
	lastPlayheadColPrecise = tickCountPrecise / ticksPerCol;
	jassert (lastPlayheadColPrecise >= 0.0)
	jassert (lastPlayheadColPrecise <= 16.0)
	//if (primary) {
		SharedState::getInstance()->setPlayheadColPrecise (lastPlayheadColPrecise);
	//}		
	
	if (tickCount != lastTickCount) {
		lastTickCount = tickCount;
		
		// Check if we should be degrading...
		int panelIndex = pluginAudioProcessor->getPanelIndex();
      int state = SharedState::getInstance()->getState(panelIndex);
      if (state == Panel::DEGRADING_SLOW ||
          state == Panel::DEGRADING_FAST) {
         // degrade at most once per tempo sweep, in column 0
         if (getPlayheadCol() == 0) {
            if (!columnZeroDegradeUpdate) {
               SharedState::getInstance()->degradeStep(panelIndex);
               columnZeroDegradeUpdate = true;
            }
         } else {
            columnZeroDegradeUpdate = false;
         }
      } else {
         columnZeroDegradeUpdate = false;
         if (state == Panel::ACTIVE) {
            // XXX bug:67 - switch to Time::currentTimeMillis() ?
            if (SharedState::kDegradeAfterInactiveSec > 0 &&
                SharedState::getInstance()->getTimeInSeconds() >= 
                (SharedState::getInstance()->getLastTouchSecond(panelIndex) + 
                 SharedState::kDegradeAfterInactiveSec)) {
               DBG(String(Time::currentTimeMillis()) + " "
                   + "Start degrading panel " + String(panelIndex));
               SharedState::getInstance()->startDegrade(panelIndex);
            }
         }
      }
		
		// Update starfield if necessary
      // XXX bug:67 verify state ?
		if (SharedState::getInstance()->getStarFieldActive()) {
			if (pluginAudioProcessor->getPanelIndex() == 0) {
				if (tickCount % 10 == 0) {			
					SharedState::getInstance()->updateStarField();
				}
			}
		}
		
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
		
		// Send any upcoming note-off events
		Array<NoteOff*> notesToRemove; 
		for (int i = 0; i < noteOffs.size(); i++) {
			if (noteOffs[i]->tick == tickCount) {
				int noteNumber = noteOffs[i]->noteNumber;
				MidiMessage m2 = MidiMessage::noteOff (1, noteNumber);
				midiMessages.addEvent (m2, tickOffsetSamples);			
				playingNotes.set (noteNumber, false);

				notesToRemove.add (noteOffs[i]);
			}
		}
		for (int i = 0; i < notesToRemove.size(); i++) {
			// Remove the event from the note-off event list
			// (We do this in two steps so that the noteOffs array isn't modified inside a loop)
			noteOffs.removeObject (notesToRemove[i], true);
		}		
		
		// If we should play the current column of notes
		if (playCol) {
			int panelIndex = pluginAudioProcessor->getPanelIndex();
			int tabIndex = pluginAudioProcessor->getTabIndex();

			for (int i = 0; i < getTotalRows(); i++) {
				Cell* cell = getCellAt (panelIndex, tabIndex, i, getPlayheadCol());
            if (cell->isOn()) {
               int noteNumber = cell->getNoteNumber();
					// If this note is currently playing
					if (playingNotes[noteNumber] == true) {
						Array<NoteOff*> notesToRemove;
						// Remove any pending note-offs
						for (int j = 0; j < noteOffs.size(); j++) {
							if (noteOffs[j]->noteNumber == noteNumber) {
								notesToRemove.add (noteOffs[j]);
							}
						}
						for (int j = 0; j < notesToRemove.size(); j++) {
							noteOffs.removeObject (notesToRemove[j], true);
						}
						// Send a note-off before retriggering
						MidiMessage m = MidiMessage::noteOff (1, noteNumber);
						midiMessages.addEvent (m, tickOffsetSamples);
						playingNotes.set (noteNumber, false);

					}
					// Play this note
					MidiMessage m = MidiMessage::noteOn (1, noteNumber, velocity);
					midiMessages.addEvent (m, tickOffsetSamples);
					playingNotes.set (noteNumber, true);
					
					// Add an upcoming note-off event
					NoteOff* no;
					noteOffs.add (no = new NoteOff());
					no->tick = (tickCount + noteLength) % (ticksPerCol * getTotalCols());
					no->noteNumber = noteNumber;
				}
			}
		}
	}
}
