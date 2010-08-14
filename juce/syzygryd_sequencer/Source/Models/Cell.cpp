/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  Cell.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 4/9/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"

// From the pentatonic scale. In ascending order:
//   C4, D4, E4, G4, A4, C5, D5, E5, G5, A5
//   http://upload.wikimedia.org/wikipedia/commons/7/7a/NoteNamesFrequenciesAndMidiNumbers.svg
// backwards here b/c row 0 is the top row, which is the highest note
const int Cell::scale[] = {
   81, 79, 76, 74, 72, 69, 67, 64, 62, 60
};

const int Cell::NOTE_OFF = -1;

Cell::Cell (int row_, int col_) :
northCell (0),
westCell (0),
eastCell (0),
southCell (0),
row (row_),
col (col_),
noteNumber (NOTE_OFF)
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

bool Cell::isOn()
{
   return (noteNumber != NOTE_OFF);
}

void Cell::setNoteNumber (int noteNumber_)
{
	noteNumber = noteNumber_;
}

void Cell::setNoteOff()
{
	setNoteNumber (NOTE_OFF);	
}

void Cell::setNoteOn()
{
   jassert (row >= 0 && row < 10);
	setNoteNumber (scale[row]);
}
