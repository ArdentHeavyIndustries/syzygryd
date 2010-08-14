/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
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

   enum PanelState { ACTIVE, DEGRADING_SLOW, DEGRADING_FAST, DEGRADED, ATTRACT };
	
	static const int kNumTabs;
	
	int getTabIndex();
	void setTabIndex (int tabIndex_);
	
	Cell* getCellAt (int tabIndex_, int row_, int col_);	
	
	void clearTab (int tabIndex_);
	
	void updateStarField();

   // bug:67
   // XXX change these to use Time::currentTimeMillis() ?
	double getLastTouchSecond();
	void setLastTouchSecond (double lastTouchSecond_);
   void setState(int state_);
   int getState();
   void startDegrade();
   void degradeStep();
   void degradeOne();
   void stopDegrade();
   bool isDegrading();
	
private:
	OwnedArray<Tab> tabs;	
	
	int tabIndex; // which tab is currently selected?

   // bug:67
	double lastTouchSecond;
   int state;
   Random* random;
   Array<Cell*> cellsToDegrade;
   int64 timeStartDegradeMs;
   int64 timeDegradeStepMs;
   float fastSecPerDelete;
};

#endif
