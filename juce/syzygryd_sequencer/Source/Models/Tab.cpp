/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  Tab.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "StarField.h"
#include "SharedState.h"

#include "Tab.h"

Tab::Tab (int totalRows_, int totalCols_) :
totalRows (totalRows_),
totalCols (totalCols_),
starField (0),
updateStarFieldCount (0),
firstUpdateStarField (true)
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
	
	starField = new StarField (totalRows, totalCols);
}

Tab::~Tab()
{
	deleteAndZero (starField);
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

void Tab::updateStarField()
{
	int kUpdateStarFieldSkip = SharedState::getInstance()->getUpdateStarFieldSkip();
	
	//DBG("Tab::updateStarField()");
	if (firstUpdateStarField) {
		firstUpdateStarField = false;
		skipIntoStarField();
	}
	
	updateStarFieldCount++;
	if (updateStarFieldCount <= kUpdateStarFieldSkip) {
		return;
	}
	updateStarFieldCount = 0;
	
	if (SharedState::getInstance()->getStarFieldActive()) {
		starField->update();
		
		for (int i = 0; i < totalRows; i++) {
			for (int j = 0; j < totalCols; j++) {
				bool active = starField->getActiveAt (i, j);
				
				Cell* cell = getCellAt (i, j);
				if (active) {
					cell->setNoteOn();
				} else {
					cell->setNoteOff();
				}
			}
		}		
	}
}

void Tab::skipIntoStarField()
{
	// Skip some frames into the animation (so it doesn't take so long to load)
	for (int i = 0; i < 20; i++) {
		starField->update();
	}	
}

