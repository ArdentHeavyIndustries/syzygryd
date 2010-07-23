/*
 *  SequencerComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "Sequencer.h"
#include "PluginAudioProcessor.h"
#include "CellComponent.h"

#include "SequencerComponent.h"

SequencerComponent::SequencerComponent (PluginAudioProcessor* pluginAudioProcessor_) :
Component ("SequencerComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
lastPlayheadCol (-1),
lastPanelIndex (-1),
lastTabIndex (-1),
lastToggledCellComponent (0)
{
	sequencer = pluginAudioProcessor->getSequencer();
	
	for (int i = 0; i < sequencer->getTotalRows(); i++) {
		Array<CellComponent*>* row;
		rows.add (row = new Array<CellComponent*>);
		for (int j = 0; j < sequencer->getTotalCols(); j++) {
			int panelIndex = pluginAudioProcessor->getPanelIndex();
			int tabIndex = pluginAudioProcessor->getTabIndex();
			CellComponent* cell;
			addAndMakeVisible (cell = new CellComponent (pluginAudioProcessor,
														 sequencer->getCellAt (panelIndex, tabIndex, i, j)));
			row->add (cell);
			cell->addMouseListener (this, false);
		}
	}
	
	setSize (600, 400);
	setWantsKeyboardFocus (true);
	
	setAlwaysOnTop (true);
	
	startTimer (50);
}

SequencerComponent::~SequencerComponent()
{
	deleteAllChildren();
}

CellComponent* SequencerComponent::getCellAt (int row_, int col_)
{
	Array<CellComponent*>* row = rows[row_];
	CellComponent* cell = row->getUnchecked (col_);
	return cell;
}

// Component methods
void SequencerComponent::paint (Graphics& g)
{
	g.setColour (Colour::fromRGB (20, 50, 40));
	g.fillAll();
	
	g.setColour (Colour::fromRGB (60, 120, 100));

	float cellWidth = (float)getWidth() / sequencer->getTotalCols();
	g.fillRect (lastPlayheadCol * cellWidth, 0.0f, cellWidth, 
				(float)getHeight());
}

void SequencerComponent::resized()
{
	float cellWidth = (float)getWidth() / sequencer->getTotalCols();
	float cellHeight = (float)getHeight() / sequencer->getTotalRows();
	
	for (int i = 0; i < sequencer->getTotalRows(); i++) {
		for (int j = 0; j < sequencer->getTotalCols(); j++) {
			CellComponent* cell = getCellAt (i, j);
			cell->setBounds (j * cellWidth, i * cellHeight, cellWidth, cellHeight);
		}
	}
}

void SequencerComponent::mouseDown (const MouseEvent& e)
{
	handleMouseEvent (e);
}

void SequencerComponent::mouseDrag (const MouseEvent& e)
{
	handleMouseEvent (e);
}

void SequencerComponent::handleMouseEvent (const MouseEvent& e)
{
	Component *c = getComponentAt (e.getEventRelativeTo(this).getPosition());
	CellComponent *cellComponent = dynamic_cast<CellComponent*> (c);
	
	if (cellComponent != 0) {
		if (cellComponent != lastToggledCellComponent) {
			cellComponent->toggleNote();
			lastToggledCellComponent = cellComponent;
		}
	}	
}

// Timer methods
void SequencerComponent::timerCallback()
{
	lastPlayheadCol = sequencer->getPlayheadCol();
	repaint();
	
	if (lastPanelIndex != pluginAudioProcessor->getPanelIndex() 
		|| lastTabIndex != pluginAudioProcessor->getTabIndex()) {
		lastPanelIndex = pluginAudioProcessor->getPanelIndex();
		lastTabIndex = pluginAudioProcessor->getTabIndex();
		
		for (int i = 0; i < sequencer->getTotalRows(); i++) {
			for (int j = 0; j < sequencer->getTotalCols(); j++) {
				CellComponent* cellComponent = getCellAt (i, j);
				Cell* cell = sequencer->getCellAt (lastPanelIndex, lastTabIndex, 
												   i, j);
				cellComponent->setCell (cell);
			}
		}		
	}
}
