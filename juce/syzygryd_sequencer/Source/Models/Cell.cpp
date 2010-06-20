/*
 *  Cell.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 4/9/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"

Cell::Cell (int row_, int col_) :
northCell (0),
westCell (0),
eastCell (0),
southCell (0),
row (row_),
col (col_),
noteNumber (-1)
{
}

Cell::~Cell()
{
}

void Cell::setNorthCell (Cell* northCell_)
{
	northCell = northCell_;
}

void Cell::setWestCell (Cell* westCell_)
{
	westCell = westCell_;
}

void Cell::setEastCell (Cell* eastCell_)
{
	eastCell = eastCell_;
}

void Cell::setSouthCell (Cell* southCell_)
{
	southCell = southCell_;
}

Cell* Cell::getNorthCell()
{
	if (!northCell) return this;
	return northCell;
}

Cell* Cell::getWestCell()
{
	if (!westCell) return this;
	return westCell;
}

Cell* Cell::getEastCell()
{
	if (!eastCell) return this;
	return eastCell;
}

Cell* Cell::getSouthCell()
{
	if (!southCell) return this;
	return southCell;
}

int Cell::getRow()
{
	return row;
}

void Cell::setRow (int row_)
{
	row = row_;
}

int Cell::getCol()
{
	return col;
}

void Cell::setCol (int col_)
{
	col = col_;
}

int Cell::getNoteNumber()
{
	return noteNumber;
}

void Cell::setNoteNumber (int noteNumber_)
{
	noteNumber = noteNumber_;
}

void Cell::setNoteOff()
{
	setNoteNumber (-1);	
}

void Cell::setNoteOn()
{
	setNoteNumber (69 - row);	
}







