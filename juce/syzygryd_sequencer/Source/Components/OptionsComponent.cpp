/*
 *  OptionsComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "PluginAudioProcessor.h"
#include "Sequencer.h"

#include "OptionsComponent.h"

static const int kRadioGroupId = 123;
static const int kRadioSize = 3;
static const int kRadioHeight = 26;
static const int kRadioWidth = 47;

OptionsComponent::OptionsComponent (PluginAudioProcessor* pluginAudioProcessor_):
Component ("OptionsComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
lastPanelIndex (-1)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = new TextButton ("Pan " + String(i));
		radioButton->setRadioGroupId (kRadioGroupId + 1);
		radioButton->setColour (TextButton::buttonOnColourId, Colour::fromRGB (150, 150, 240));
		if (i == 0) radioButton->setToggleState (true, false);
		radioButton->setClickingTogglesState (true);
		radioButton->addButtonListener (this);
		addAndMakeVisible (radioButton);
		panelButtons.add (radioButton);
	}
	
	startTimer (1000);
}

OptionsComponent::~OptionsComponent()
{
}

// Component methods
void OptionsComponent::paint (Graphics& g)
{
}

void OptionsComponent::resized()
{
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = panelButtons[i];
		radioButton->setBounds ((i * kRadioWidth), 40, kRadioWidth, kRadioHeight);
		radioButton->setConnectedEdges (((i != 0) ? Button::ConnectedOnLeft : 0) 
										| ((i != kRadioSize - 1) ? Button::ConnectedOnRight : 0));
	}
}

// ButtonListener methods
void OptionsComponent::buttonClicked (Button* button)
{
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = panelButtons[i];
		if (button == radioButton) {
			pluginAudioProcessor->setPanelIndex (i);
		}
	}		
}

// Timer methods
void OptionsComponent::timerCallback()
{
	if (lastPanelIndex != pluginAudioProcessor->getPanelIndex()) {
		lastPanelIndex = pluginAudioProcessor->getPanelIndex();

		TextButton* radioButton = panelButtons[lastPanelIndex];
		radioButton->setToggleState (true, false);
	}
}



