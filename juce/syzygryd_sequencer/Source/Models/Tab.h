/*
 *  Tab.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef Tab_H
#define Tab_H

#include "JuceHeader.h"

class Cell;

class StarField;

class Tab 
{
public:
	Tab (int totalRows_, int totalCols_);
	~Tab();
	
	Cell* getCellAt (int row_, int col_);	

	void clear();
	
	void update();
	
private:
	const int totalRows;
	const int totalCols;
	
	OwnedArray< OwnedArray<Cell> > rows;	
	
	StarField* starField;
	
	int updateCount;
	bool firstUpdate;
};

#endif
