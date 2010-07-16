/*
 *  AdjustmentComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/15/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "AdjustmentComponent.h"

#include "PluginAudioProcessor.h"
#include "Sequencer.h"

AdjustmentComponent::AdjustmentComponent (PluginAudioProcessor* pluginAudioProcessor_) :
Component ("AdjustmentComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
noteLengthSlider (0),
lastNoteLength (-1)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	addAndMakeVisible (noteLengthSlider = new Slider ("Note Length"));
	noteLengthSlider->setSliderStyle (Slider::LinearHorizontal);
	noteLengthSlider->setRange (0, 20, 1.0);
	noteLengthSlider->setValue (1.0, false, false);
	noteLengthSlider->setTextBoxStyle (Slider::NoTextBox, false, 100, 20);
	noteLengthSlider->addListener (this);
	
	startTimer (100);
}

AdjustmentComponent::~AdjustmentComponent()
{
	deleteAllChildren();
}

// Component methods
void AdjustmentComponent::paint (Graphics& g)
{
	g.setColour (Colour::fromRGB (255,255,255));
	g.drawText ("Note Length:", 0, 20, 100, 20, Justification::centredLeft, false);
}

void AdjustmentComponent::resized()
{
	noteLengthSlider->setBounds (100, 10, getWidth() - 120, getHeight());
}

// Timer methods
void AdjustmentComponent::timerCallback()
{
	if (lastNoteLength != sequencer->getNoteLength()) {
		noteLengthSlider->setValue (sequencer->getNoteLength(), false, false);
		lastNoteLength = sequencer->getNoteLength();
	}
}

// SliderListener methods
void AdjustmentComponent::sliderValueChanged (Slider* slider)
{
	sequencer->setNoteLength (slider->getValue());
}	



