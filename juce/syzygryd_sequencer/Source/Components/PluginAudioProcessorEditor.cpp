/*
 *  PluginAudioProcessorEditor.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "MainComponent.h"
#include "PluginAudioProcessor.h"

#include "PluginAudioProcessorEditor.h"

PluginAudioProcessorEditor::PluginAudioProcessorEditor (PluginAudioProcessor* pluginAudioProcessor) : 
AudioProcessorEditor (pluginAudioProcessor),
resizer (0),
mainComponent (0),
standalone (false)
{
	addAndMakeVisible (mainComponent = new MainComponent (pluginAudioProcessor));

	addAndMakeVisible (resizer = new ResizableCornerComponent (this, &resizeLimits));	
	resizeLimits.setSizeLimits (600, 400, 2400, 1600);
	
	addComponentListener (this);
	
	setSize (600, 400);
}

PluginAudioProcessorEditor::~PluginAudioProcessorEditor()
{
	removeComponentListener (this);
	deleteAllChildren();
}

bool PluginAudioProcessorEditor::getStandalone()
{
	return standalone;
}

void PluginAudioProcessorEditor::setStandalone (bool standalone_)
{
	standalone = standalone_;
}

PluginAudioProcessor* PluginAudioProcessorEditor::getPluginAudioProcessor() const
{
	return static_cast <PluginAudioProcessor*> (getAudioProcessor());
}	

// Component methods
void PluginAudioProcessorEditor::paint (Graphics& g)
{
}

void PluginAudioProcessorEditor::resized() 
{
	mainComponent->setBounds (0, 0, getWidth(), getHeight());
	if (resizer != 0) {
		resizer->setBounds (getWidth() - 16, getHeight() - 16, 16, 16);
	}
}

// ComponentListener methods
void PluginAudioProcessorEditor::componentParentHierarchyChanged (Component& component)
{
	if (! standalone) return;
	
	// Add resizer after standalone window has been created.
	if (resizer != 0) deleteAndZero (resizer);
	Component* topLevelComponent = getTopLevelComponent();
	addAndMakeVisible (resizer = new ResizableCornerComponent (topLevelComponent, 
															   &resizeLimits));
	resized();
}

