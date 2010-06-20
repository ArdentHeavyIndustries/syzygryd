/*
 *  AudioProcessorCallback.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef AudioCallback_H
#define AudioCallback_H

#include "JuceHeader.h"

class AudioProcessorCallback
{
public:
	AudioProcessorCallback (AudioProcessor* audioProcessor_);
	virtual ~AudioProcessorCallback();

	AudioProcessor* getAudioProcessor();
    
	virtual void prepareToPlay (double sampleRate, int samplesPerBlock) = 0;
    virtual void releaseResources() = 0;
    virtual void processBlock (AudioSampleBuffer& buffer, 
							   MidiBuffer& midiMessages) = 0;

private:
	AudioProcessor* audioProcessor;
};

#endif
