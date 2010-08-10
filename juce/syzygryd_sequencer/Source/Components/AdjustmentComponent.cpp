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
lastNoteLength (-1),
swingTicksSlider (0),
lastSwingTicks (-1)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	addAndMakeVisible (noteLengthSlider = new Slider ("Note Length"));
	noteLengthSlider->setSliderStyle (Slider::LinearHorizontal);
	noteLengthSlider->setRange (0, sequencer->getMaxNoteLength(), 1.0);
	noteLengthSlider->setValue (1.0, false, false);
	noteLengthSlider->setTextBoxStyle (Slider::NoTextBox, false, 100, 20);
	noteLengthSlider->addListener (this);
	
	addAndMakeVisible (swingTicksSlider = new Slider ("Swing Ticks"));
	swingTicksSlider->setSliderStyle (Slider::LinearHorizontal);
	swingTicksSlider->setRange (0, sequencer->getMaxSwingTicks(), 1.0);
	swingTicksSlider->setValue (0, false, false);
	swingTicksSlider->setTextBoxStyle (Slider::NoTextBox, false, 100, 20);
	swingTicksSlider->addListener (this);
	
	startTimer (100);
}

AdjustmentComponent::~AdjustmentComponent()
{
	noteLengthSlider->removeListener (this);
	swingTicksSlider->removeListener (this);
	deleteAllChildren();
}

// Component methods
void AdjustmentComponent::paint (Graphics& g)
{
	g.setColour (Colour::fromRGB (255,255,255));
	g.drawText ("Note Length:", 0, 20, 100, 20, Justification::centredLeft, false);

	g.setColour (Colour::fromRGB (255,255,255));
	g.drawText ("Swing:", getWidth() * 0.5, 20, 100, 20, Justification::centredLeft, false);
}

void AdjustmentComponent::resized()
{
	noteLengthSlider->setBounds (100, 10, getWidth() * 0.5 - 120, getHeight());
	swingTicksSlider->setBounds (getWidth() * 0.5 + 50, 10, getWidth() * 0.5 - 70, getHeight());
}

// Timer methods
void AdjustmentComponent::timerCallback()
{
	if (lastNoteLength != sequencer->getNoteLength()) {
		noteLengthSlider->setValue (sequencer->getNoteLength(), false, false);
		lastNoteLength = sequencer->getNoteLength();
	}
	if (lastSwingTicks != sequencer->getSwingTicks()) {
		swingTicksSlider->setValue (sequencer->getSwingTicks(), false, false);
		lastSwingTicks = sequencer->getSwingTicks();
		noteLengthSlider->setRange (0, sequencer->getMaxNoteLength(), 1.0);
	}
}

// SliderListener methods
void AdjustmentComponent::sliderValueChanged (Slider* slider)
{
	if (slider == noteLengthSlider) {
		sequencer->setNoteLength (slider->getValue());
		float newParam = pluginAudioProcessor->getParameter (pluginAudioProcessor->noteLengthParam);
		pluginAudioProcessor->setParameterNotifyingHost (pluginAudioProcessor->noteLengthParam, newParam);
	} else if (slider == swingTicksSlider) {
		sequencer->setSwingTicks (slider->getValue());
		float newParam = pluginAudioProcessor->getParameter (pluginAudioProcessor->swingTicksParam);
		pluginAudioProcessor->setParameterNotifyingHost (pluginAudioProcessor->swingTicksParam, newParam);
	}
}	



