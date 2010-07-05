/*
 *  CellComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "PluginAudioProcessor.h"
#include "Sequencer.h"

#include "CellComponent.h"

CellComponent::CellComponent (PluginAudioProcessor* pluginAudioProcessor_, 
							  Cell* cell_) :
Component ("CellComponent"),
pluginAudioProcessor (pluginAudioProcessor_),
cell (cell_)
{
	sequencer = pluginAudioProcessor->getSequencer();
}

CellComponent::~CellComponent()
{
}

void CellComponent::setCell (Cell* cell_) {
	cell = cell_;
}

// Component methods
void CellComponent::paint (Graphics& g)
{
	if (cell->getNoteNumber() >= 0) {
		g.setColour (Colour::fromRGB (100, 140, 110));
	} else {
		g.setColour (Colour::fromRGB (20, 40, 30));
	}
	g.fillRect (5, 5, getWidth() - 10, getHeight() - 10);
	g.setColour (Colour::fromRGB (50, 100, 80));
	g.drawRect (5, 5, getWidth() - 10, getHeight() - 10, 1.0);
	 
	/*
	String label;
	label << cell->getRow() << ", " << cell->getCol();
	g.setColour (Colour::fromRGB (200, 200, 200));
	g.setFont (11);
	g.drawText (label, 5, 5, getWidth() - 10, getHeight() - 10, Justification::centred, false);
	*/
}

void CellComponent::resized()
{
}

void CellComponent::mouseDown (const MouseEvent& e)
{
	int panelIndex = pluginAudioProcessor->getPanelIndex();
	int tabIndex = pluginAudioProcessor->getTabIndex();
	bool sendNoteOn = (cell->getNoteNumber() <= 0);
	
	sequencer->noteToggle (panelIndex, tabIndex, cell->getRow(), cell->getCol(), 
						   sendNoteOn);
	repaint();
}



