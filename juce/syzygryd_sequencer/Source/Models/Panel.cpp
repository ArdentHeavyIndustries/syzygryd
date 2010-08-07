/* -*- mode: C++; c-basic-offset: 3; indent-tabs-mode: nil -*- */
/*
 *  Panel.cpp
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 7/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "Cell.h"
#include "Tab.h"

#include "Panel.h"

const int Panel::kNumTabs = 4;

Panel::Panel (int totalRows_, int totalCols_) :
tabIndex (0),
lastTouchSecond (0)
{
	for (int i = 0; i < kNumTabs; i++) {
		Tab* tab = new Tab (totalRows_, totalCols_);
		tabs.add (tab);
	}
}

Panel::~Panel()
{
}

int Panel::getTabIndex()
{
	return tabIndex;
}

void Panel::setTabIndex (int tabIndex_)
{
	tabIndex = tabIndex_;
}

Cell* Panel::getCellAt (int tabIndex_, int row_, int col_)
{
	Tab* tab = tabs[tabIndex_];
	Cell* cell = tab->getCellAt (row_, col_);
	return cell;
}

void Panel::clearTab (int tabIndex_)
{
	Tab* tab = tabs[tabIndex_];
	tab->clear();
}

void Panel::update()
{
	/*
	for (int i = 0; i < kNumTabs; i++) {
		Tab* tab = tabs[i];
		tab->update();
	}
	 */
	tabs[tabIndex]->update();
}

double Panel::getLastTouchSecond()
{
	return lastTouchSecond;
}

void Panel::setLastTouchSecond (double lastTouchSecond_)
{
	lastTouchSecond = lastTouchSecond_;
}





