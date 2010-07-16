/*
 *  PluginAudioProcessor.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef PLUGIN_AUDIO_PROCESSOR_H
#define PLUGIN_AUDIO_PROCESSOR_H

#include "JuceHeader.h"
#include "JucePluginCharacteristics.h"

class CustomPlayHead;
class Sequencer;

class PluginAudioProcessor : public AudioProcessor
{
public:
    PluginAudioProcessor();
    ~PluginAudioProcessor();

	void setCustomPlayHead (CustomPlayHead* customPlayHead_);
	Sequencer* getSequencer();
	void setSequencer (Sequencer* sequencer_);

	int getPanelIndex();
	void setPanelIndex (int panelIndex_);
	int getTabIndex();
	void setTabIndex (int tabIndex_);
	
	// AudioProcessor methods
    void prepareToPlay (double sampleRate, int samplesPerBlock);
    void releaseResources();
    void processBlock (AudioSampleBuffer& buffer, MidiBuffer& midiMessages);

    AudioProcessorEditor* createEditor();

    const String getName() const;

    int getNumParameters();
    float getParameter (int index);
    void setParameter (int index, float newValue);
	const String getParameterName (int index);
    const String getParameterText (int index);
    
	const String getInputChannelName (const int channelIndex) const;
    const String getOutputChannelName (const int channelIndex) const;
	bool isInputChannelStereoPair (int index) const;
    bool isOutputChannelStereoPair (int index) const;
    
	bool acceptsMidi() const;
    bool producesMidi() const;

    int getNumPrograms();
    int getCurrentProgram();
    void setCurrentProgram (int index);
    const String getProgramName (int index);
    void changeProgramName (int index, const String& newName);

    void getStateInformation (MemoryBlock& destData);
    void setStateInformation (const void* data, int sizeInBytes);
	
	//--------------------------------------------------------------------------
	enum Parameters {
		noteLengthParam = 0,
		swingTicksParam = 1,
		
		totalNumParams
	};
	
	AudioPlayHead::CurrentPositionInfo lastPosInfo;

    juce_UseDebuggingNewOperator

private:
	float getLerp (float start, float startMin, float startMax, 
				   float endMin, float endMax);
	
	CustomPlayHead* customPlayHead;

	Sequencer* sequencer;	
	
	int panelIndex;
};

#endif  
