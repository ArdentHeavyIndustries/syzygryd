/*
 *  PluginAudioProcessor.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PluginAudioProcessorEditor.h"
#include "CustomPlayHead.h"
#include "Sequencer.h"
#include "SharedState.h"

#include "PluginAudioProcessor.h"

PluginAudioProcessor::PluginAudioProcessor() :
customPlayHead (0),
sequencer (0),
panelIndex (0)
{
	sequencer = new Sequencer (this);
}

PluginAudioProcessor::~PluginAudioProcessor()
{
	delete sequencer;
}

void PluginAudioProcessor::setCustomPlayHead (CustomPlayHead* customPlayHead_)
{
	customPlayHead = customPlayHead_;
}

Sequencer* PluginAudioProcessor::getSequencer()
{
	return sequencer;
}

void PluginAudioProcessor::setSequencer (Sequencer* sequencer_)
{
	sequencer = sequencer_;
}

int PluginAudioProcessor::getPanelIndex()
{
	return panelIndex;
}

void PluginAudioProcessor::setPanelIndex (int panelIndex_)
{
	panelIndex = panelIndex_;
}

int PluginAudioProcessor::getTabIndex()
{
	return SharedState::getInstance()->getTabIndex (panelIndex);
}

void PluginAudioProcessor::setTabIndex (int tabIndex_)
{
	SharedState::getInstance()->setTabIndex (panelIndex, tabIndex_);
}

// AudioProcessor methods
const String PluginAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

int PluginAudioProcessor::getNumParameters()
{
    return 0;
}

float PluginAudioProcessor::getParameter (int index)
{
	switch (index) {
		default:        return 0.0f;
	}
}

void PluginAudioProcessor::setParameter (int index, float newValue)
{
	switch (index) {
		default:        break;
	}	
}

const String PluginAudioProcessor::getParameterName (int index)
{
	switch (index) {
		default:        return String::empty;
	}
}

const String PluginAudioProcessor::getParameterText (int index)
{
    return String (getParameter (index), 2);
}

const String PluginAudioProcessor::getInputChannelName (const int channelIndex) const
{
    return String (channelIndex + 1);
}

const String PluginAudioProcessor::getOutputChannelName (const int channelIndex) const
{
    return String (channelIndex + 1);
}

bool PluginAudioProcessor::isInputChannelStereoPair (int index) const
{
    return true;
}

bool PluginAudioProcessor::isOutputChannelStereoPair (int index) const
{
    return true;
}

bool PluginAudioProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
    return true;
#else
    return false;
#endif
}

bool PluginAudioProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
    return true;
#else
    return false;
#endif
}

int PluginAudioProcessor::getNumPrograms()
{
    return 0;
}

int PluginAudioProcessor::getCurrentProgram()
{
    return 0;
}

void PluginAudioProcessor::setCurrentProgram (int index)
{
}

const String PluginAudioProcessor::getProgramName (int index)
{
    return String::empty;
}

void PluginAudioProcessor::changeProgramName (int index, const String& newName)
{
}

void PluginAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..

	setLatencySamples (0.0115 * sampleRate);
	
	if (customPlayHead != 0) customPlayHead->prepareToPlay (sampleRate, samplesPerBlock);
	if (sequencer != 0) sequencer->prepareToPlay (sampleRate, samplesPerBlock);
}

void PluginAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
	if (customPlayHead != 0) customPlayHead->releaseResources();
	if (sequencer != 0) sequencer->releaseResources();
}

void PluginAudioProcessor::processBlock (AudioSampleBuffer& buffer, MidiBuffer& midiMessages)
{
	if (customPlayHead != 0) customPlayHead->processBlock (buffer, midiMessages);
	
	// Record the current time
	AudioPlayHead::CurrentPositionInfo newTime;
	if (getPlayHead() != 0 && getPlayHead()->getCurrentPosition (newTime)) {
		lastPosInfo = newTime;
	} else {
		lastPosInfo.resetToDefault();
	}
	
	// Run the sequencer
	if (sequencer != 0) sequencer->processBlock (buffer, midiMessages);
	
	buffer.clear();
	
    // In case we have more outputs than inputs, we'll clear any output
    // channels that didn't contain input data, (because these aren't
    // guaranteed to be empty - they may contain garbage).
    for (int i = getNumInputChannels(); i < getNumOutputChannels(); ++i)
    {
        buffer.clear (i, 0, buffer.getNumSamples());
    }
}

AudioProcessorEditor* PluginAudioProcessor::createEditor()
{
    return new PluginAudioProcessorEditor (this);
}

void PluginAudioProcessor::getStateInformation (MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void PluginAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
	// This creates new instances of the plugin..
    return new PluginAudioProcessor();
}
