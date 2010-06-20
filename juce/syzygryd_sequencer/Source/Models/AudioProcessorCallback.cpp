/*
 *  AudioProcessorCallback.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "AudioProcessorCallback.h"


AudioProcessorCallback::AudioProcessorCallback (AudioProcessor* audioProcessor_) :
audioProcessor (audioProcessor_)
{
}

AudioProcessorCallback::~AudioProcessorCallback()
{
}

AudioProcessor* AudioProcessorCallback::getAudioProcessor()
{
	return audioProcessor;
}





