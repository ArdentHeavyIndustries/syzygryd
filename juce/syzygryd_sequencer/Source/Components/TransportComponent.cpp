/*
 *  TransportComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/7/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "CustomPlayHead.h"

#include "TransportComponent.h"

TransportComponent::TransportComponent (AudioProcessor* audioProcessor_) :
Component ("TransportComponent"),
audioProcessor (audioProcessor_),
bpmSlider (0),
playButton (0)
{
	
	addAndMakeVisible (bpmSlider = new Slider ("bpmSlider"));
	bpmSlider->setSliderStyle (Slider::RotaryVerticalDrag);
	bpmSlider->setRange (30.0, 200.0, 0.10);
	bpmSlider->setValue (128.0, true, false);
	bpmSlider->setTextBoxStyle (Slider::TextBoxRight, false, 100, 20);
	bpmSlider->addListener (this);
	
	addAndMakeVisible (playButton = new TextButton ("Play"));
	playButton->addButtonListener (this);
}

TransportComponent::~TransportComponent()
{
	bpmSlider->removeListener (this);
	deleteAllChildren();
}

CustomPlayHead* TransportComponent::getPlayHead()
{
	CustomPlayHead* customPlayHead = dynamic_cast<CustomPlayHead*> (audioProcessor->getPlayHead());
	jassert (customPlayHead != 0)

	return customPlayHead;
}

// Component methods
void TransportComponent::paint (Graphics& g)
{
	g.fillAll (Colour::fromRGB (230, 230, 250));
}

void TransportComponent::resized()
{
	bpmSlider->setBounds (110, 10, 200, 30);
	playButton->setBounds (10, 10, 100, 30);
}

// ButtonListener methods
void TransportComponent::buttonClicked (Button* button)
{
	if (button == playButton) {
		CustomPlayHead* customPlayHead = getPlayHead();
		if (customPlayHead->isPlaying()) {
			customPlayHead->stop();
			playButton->setButtonText ("Play");
		} else {
			customPlayHead->play();
			playButton->setButtonText ("Stop");
		}
	}
}

// SliderListener methods
void TransportComponent::sliderValueChanged (Slider* slider)
{
	if (slider == bpmSlider) {
		CustomPlayHead* customPlayHead = getPlayHead();
		customPlayHead->setBPM (slider->getValue());
	}
}

