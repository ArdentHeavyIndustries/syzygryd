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
#include "SharedState.h"

#include "OptionsComponent.h"

static const int kRadioGroupId = 123;
static const int kRadioSize = 3;
static const int kRadioHeight = 26;
static const int kRadioWidth = 47;

OptionsComponent::OptionsComponent (PluginAudioProcessor* pluginAudioProcessor_):
Component ("OptionsComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
lastPanelIndex (-1),
starFieldButton (0),
lastStarFieldActive (false)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = new TextButton ("Panel " + String(i + 1));
		radioButton->setRadioGroupId (kRadioGroupId + 1);
		radioButton->setColour (TextButton::buttonOnColourId, Colour::fromRGB (150, 150, 240));
		if (i == 0) radioButton->setToggleState (true, false);
		radioButton->setClickingTogglesState (true);
		radioButton->addButtonListener (this);
		addAndMakeVisible (radioButton);
		panelButtons.add (radioButton);
	}
	
	addAndMakeVisible (starFieldButton = new ToggleButton ("Activate Starfield"));
	starFieldButton->setColour (ToggleButton::textColourId, Colour::greyLevel (0.8));
	starFieldButton->addButtonListener (this);
	
	startTimer (1000);
}

OptionsComponent::~OptionsComponent()
{
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = panelButtons[i];
		radioButton->removeButtonListener (this);
		removeChildComponent (radioButton);
	}	
	starFieldButton->removeButtonListener (this);
	deleteAllChildren();
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
	
	starFieldButton->setBounds (0, 0, getWidth(), 20);
}

// ButtonListener methods
void OptionsComponent::buttonClicked (Button* button)
{
	if (button == starFieldButton) {
		bool starFieldActive = starFieldButton->getToggleState();
		SharedState::getInstance()->setStarFieldActive (starFieldActive);
	}
	
	for (int i = 0; i < kRadioSize; ++i) {
		TextButton* radioButton = panelButtons[i];
		if (button == radioButton) {
			pluginAudioProcessor->setPanelIndex (i);
			return;
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
	
	if (lastStarFieldActive != SharedState::getInstance()->getStarFieldActive()) {
		lastStarFieldActive = SharedState::getInstance()->getStarFieldActive();
		starFieldButton->setToggleState (lastStarFieldActive, false);
	}
}



