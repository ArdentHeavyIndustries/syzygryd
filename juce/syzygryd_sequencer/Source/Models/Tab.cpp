/*
 *  Tab.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"

#include "Tab.h"

Tab::Tab (int totalRows_, int totalCols_) :
totalRows (totalRows_),
totalCols (totalCols_)
{
	// Initialize the cells
	for (int i = 0; i < totalRows; i++) {
		OwnedArray<Cell>* row;
		rows.add(row = new OwnedArray<Cell>);
		
		for (int j = 0; j < totalCols; j++) {
			Cell* cell;
			row->add (cell = new Cell (i, j));
			if (i != 0) {
				Cell* northCell = rows.getUnchecked (i - 1)->getUnchecked(j);
				cell->setNorthCell (northCell);
				northCell->setSouthCell (cell);
			}
			if (j != 0) {
				Cell* westCell = row->getUnchecked(j - 1);
				cell->setWestCell (westCell);
				westCell->setEastCell (cell);
			}
		}
	}	
}

Tab::~Tab()
{
}

Cell* Tab::getCellAt (int row_, int col_)
{
	OwnedArray<Cell>* row = rows[row_];
	Cell* cell = row->getUnchecked (col_);
	return cell;
}

void Tab::clear()
{
	for (int i = 0; i < totalRows; i++) {
		for (int j = 0; j < totalCols; j++) {
			Cell* cell = getCellAt (i, j);
			cell->setNoteOff();
		}
	}		
}


