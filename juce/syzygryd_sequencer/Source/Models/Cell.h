/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  Cell.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 4/9/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef CELL_H
#define CELL_H

#include "JuceHeader.h"

class Cell 
{
public:
	Cell (int row_, int col_);
	~Cell();
	
	void setNorthCell (Cell* northCell_);
	void setWestCell (Cell* westCell_);
	void setEastCell (Cell* eastCell_);
	void setSouthCell (Cell* southCell_);
	
	Cell* getNorthCell();
	Cell* getWestCell();
	Cell* getEastCell();
	Cell* getSouthCell();

	int getRow();
	void setRow (int row_);
	int getCol();
	void setCol (int col_);
	
	int getNoteNumber();

	void setNoteOff();
	void setNoteOn();
	
private:
	void setNoteNumber (int noteNumber_);

   static const int scale[];
	
	Cell* northCell;
	Cell* westCell;
	Cell* eastCell;
	Cell* southCell;
	int row;
	int col;

	int noteNumber;
};

#endif
