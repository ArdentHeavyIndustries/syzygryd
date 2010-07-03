/*
 *  CellComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/17/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef CellComponent_H
#define CellComponent_H

#include "JuceHeader.h"

class Cell;

class CellComponent : public Component
{
public:
	CellComponent (Cell* cell_);
	~CellComponent();
	
	void setCell (Cell* cell_);
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();
	virtual void mouseDown (const MouseEvent& e);
	
private:
	Cell* cell;	
};

#endif
