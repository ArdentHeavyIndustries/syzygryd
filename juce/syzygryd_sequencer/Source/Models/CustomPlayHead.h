/*
 *  CustomPlayHead.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/7/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef CustomPlayHead_H
#define CustomPlayHead_H

#include "AudioProcessorCallback.h"

#include "JuceHeader.h"

class CustomPlayHead : 
public AudioPlayHead,
public AudioProcessorCallback
{
public:
	CustomPlayHead (AudioProcessor* audioProcessor);
	~CustomPlayHead();
	
	void play();
	void stop();
	bool isPlaying();
	
	void reset();
	
	double getBPM();
	void setBPM (double bpm_);
	
	// AudioPlayHead methods
	virtual bool getCurrentPosition (CurrentPositionInfo& result);
	
	// AudioProcessorCallback methods
	virtual void prepareToPlay (double sampleRate, int samplesPerBlock);
    virtual void releaseResources();
    virtual void processBlock (AudioSampleBuffer& buffer, 
							   MidiBuffer& midiMessages);

private:
	double sampleRate;
	double bpm;
	int timeSigNumerator;
	int timeSigDenominator;
	double timeInSeconds;
	double ppqPosition;
	double ppqPositionOfLastBarStart;
	bool playing;
	bool recording;
	
	double secPerBeat;
	int ppqPerBar;
	
	double timeInSecondsSinceLastBPMChange;
	double timeInSecondsOffset;
	double ppqPositionOffset;
	
	CriticalSection lock;
};

#endif
