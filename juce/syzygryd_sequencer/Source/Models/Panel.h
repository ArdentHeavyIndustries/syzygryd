/*
 *  Panel.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef Panel_H
#define Panel_H

#include "JuceHeader.h"

class Cell;
class Tab;

class Panel 
{
public:
	Panel (int totalRows_, int totalCols_);
	~Panel();
	
	int getTabIndex();
	void setTabIndex (int tabIndex_);
	
	Cell* getCellAt (int tabIndex_, int row_, int col_);	

	void clearTab (int tabIndex_);
	
private:
	OwnedArray<Tab> tabs;	
	
	int tabIndex; // which tab is currently selected?
};

#endif
