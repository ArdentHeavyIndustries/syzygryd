/*
 *  CellComponent.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"

#include "CellComponent.h"

CellComponent::CellComponent (Cell* cell_) :
Component ("CellComponent"),
cell (cell_)
{
}

CellComponent::~CellComponent()
{
}

// Component methods
void CellComponent::paint (Graphics& g)
{
	if (cell->getNoteNumber() >= 0) {
		g.setGradientFill (ColourGradient (Colour::fromRGB (170, 210, 250), getWidth() - 5, 0,
										   Colour::fromRGB (100, 140, 110), 0, getHeight(),
										   true));
	} else {
		g.setGradientFill (ColourGradient (Colour::fromRGB (90, 110, 100), getWidth() - 5, 0,
										   Colour::fromRGB (20, 40, 30), 0, getHeight(),
										   true));
	}

	g.fillRoundedRectangle (5, 5, getWidth() - 10, getHeight() - 10, 3.0);

	g.setColour (Colour::fromRGB (50, 100, 80));
	g.drawRoundedRectangle (5, 5, getWidth() - 10, getHeight() - 10, 3.0, 1.0);
	
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
	if (cell->getNoteNumber() > 0) {
		cell->setNoteOff();
	} else {
		cell->setNoteOn();
	}
	repaint();
}



