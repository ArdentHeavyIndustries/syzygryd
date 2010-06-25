/*
 *  MainComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/4/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PluginAudioProcessor.h"
#include "SequencerComponent.h"
#include "OptionsComponent.h"
#include "SidebarComponent.h"

class Sequencer;

#include "MainComponent.h"

MainComponent::MainComponent (PluginAudioProcessor* pluginAudioProcessor_) :
Component ("MainComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
positionLabel (0),
sequencerComponent (0),
optionsComponent (0),
sidebarComponent (0)
{
	addAndMakeVisible (positionLabel = new Label ("positionLabel", "Loading Position Data..."));
	positionLabel->setColour (Label::textColourId, Colour::fromRGB (120, 120, 120));
	positionLabel->setJustificationType (Justification::topLeft);
	
	Sequencer* sequencer = pluginAudioProcessor->getSequencer();
	addAndMakeVisible (sequencerComponent = new SequencerComponent (sequencer));
	addAndMakeVisible (optionsComponent = new OptionsComponent (sequencer));
	addAndMakeVisible (sidebarComponent = new SidebarComponent (sequencer));
	
	startTimer (50);
}

MainComponent::~MainComponent()
{
	deleteAllChildren();
}

// Component methods
void MainComponent::paint (Graphics& g)
{
    g.fillAll (Colours::black);

	g.setGradientFill (ColourGradient (Colour::fromRGB (250, 250, 250), 0, 15,
									   Colour::fromRGB (180, 180, 180), 0, 25,
									   false));
	
	g.setFont (18.0, Font::bold);
	g.drawText ("Syzygryd Sequencer v3.1", 10, 10, getWidth() - 20, 20, 
				Justification::centredTop, false);
}

void MainComponent::resized()
{
	positionLabel->setBounds (20, 30, getWidth() - 30, 50);
	sequencerComponent->setBounds (10, 80, getWidth() - 120, getHeight() - 90);
	optionsComponent->setBounds (getWidth() - 100, 10, 90, 50);
	sidebarComponent->setBounds (getWidth() - 110, 80, 100, getHeight() - 90);
}

// Timer methods
void MainComponent::timerCallback()
{
	AudioPlayHead::CurrentPositionInfo pos (pluginAudioProcessor->lastPosInfo);
	
	if (lastDisplayedPosition != pos) {
		lastDisplayedPosition = pos;
		String displayText;
		displayText.preallocateStorage (64);
		
		displayText 
		<< "BPM: " << String (pos.bpm, 2) << " "
		//		<< "Time Sig: " << pos.timeSigNumerator << "/" << pos.timeSigDenominator << "\n"
		<< "Recording: " << String (pos.isRecording) << " " // Doesn't work in Live 8
		<< "Playing: " << String (pos.isPlaying) << " " 
		<< "Time In Seconds: " << String (pos.timeInSeconds) << "\n"
		<< "PPQ Position: " << String (pos.ppqPosition) << " "
		<< "PPQ Position of Last Bar Start: " << String (pos.ppqPositionOfLastBarStart) << "\n"
		//<< "Edit Origin Time: " << String (pos.editOriginTime) << "\n" // Doesn't work in Live 8
		//<< "Framerate: " << String (pos.frameRate) << "\n" // Shows '99' in Live 8
		//<< "Timecode String: " << timeToTimecodeString (pos.timeInSeconds) << "\n"
		<< "Bars, Beats, & Ticks: " << ppqToBarsBeatsString (pos.ppqPosition, pos.timeSigNumerator,
													 pos.timeSigDenominator);
		
		positionLabel->setText (displayText, false);
	}
}

// Time conversion methods
const String MainComponent::timeToTimecodeString (const double seconds)
{
	const double absSecs = fabs (seconds);
	
	const int hours = (int) (absSecs / (60.0 * 60.0));
	const int mins = ((int) (absSecs / 60.0)) % 60;
	const int secs = ((int) absSecs) % 60;
						  
	String s;
	if (seconds < 0) {
		s = "-";
	}
	
	s 
	<< String (hours).paddedLeft ('0', 2) << ":"
	<< String (mins).paddedLeft ('0', 2) << ":"
	<< String (secs).paddedLeft ('0', 2) << ":"
	<< String (roundToInt (absSecs * 1000) % 1000).paddedLeft ('0', 3);
	
	return s;
}

const String MainComponent::ppqToBarsBeatsString (double ppq, int numerator, 
												  int denominator)
{
	if (numerator == 0 || denominator == 0) {
		return "1|1|0";
	}
	
	const int ppqPerBar = (numerator * 4 / denominator); // e.g. 4 if 4/4
	const double beats = (fmod (ppq, ppqPerBar) / ppqPerBar) * numerator;
	
	const int bar = ((int) ppq) / ppqPerBar + 1;
	const int beat = ((int) beats) + 1;
	const int ticks = ((int) (fmod (beats, 1.0) * 960.0));
	
	String s;
	s << bar << '|' << beat << '|' << ticks;

	return s;
}







