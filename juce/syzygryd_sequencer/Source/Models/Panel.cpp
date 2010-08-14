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
#include "SharedState.h"

#include "Panel.h"

const int Panel::kNumTabs = 4;

Panel::Panel (int totalRows_, int totalCols_) :
tabIndex (0),
lastTouchSecond (0),
state (ACTIVE)
{
	for (int i = 0; i < kNumTabs; i++) {
		Tab* tab = new Tab (totalRows_, totalCols_);
		tabs.add (tab);
	}

   random = new Random (Time::currentTimeMillis());
}

Panel::~Panel()
{
   delete random;
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

void Panel::updateStarField()
{
   DBG("Panel::updateStarField()");
   // only update the active tab with a star field, not all of the tabs
	/*
	for (int i = 0; i < kNumTabs; i++) {
		Tab* tab = tabs[i];
		tab->updateStarField();
	}
	 */
	tabs[tabIndex]->updateStarField();
}

double Panel::getLastTouchSecond()
{
	return lastTouchSecond;
}

// this should only be called if a panel is touched
void Panel::setLastTouchSecond (double lastTouchSecond_)
{
   if (isDegrading()) {
      stopDegrade();
   }
   setState(ACTIVE);
	lastTouchSecond = lastTouchSecond_;
}

void Panel::setState(int state_)
{
   // XXX bug:67 add code to verify state transitions ?
#ifdef JUCE_DEBUG
   // XXX outputting a real string would be better
   if (state_ != state) {
      DBG(String(Time::currentTimeMillis()) + " " + "Changing state from " + String(state) + " to " + String(state_));
   }
#endif
   state = state_;
}

int Panel::getState()
{
   return state;
}

void Panel::startDegrade()
{
   DBG(String(Time::currentTimeMillis()) + " " + "Start degrading panel");
   jassert(state == ACTIVE);

   // go through all of the cells that are on, and randomly insert them into
   // an array.  this will be the array that we will go through in order for
   // degrading.
   // should already be empty, but just in case
   cellsToDegrade.clear();
   DBG(String(Time::currentTimeMillis()) + " " + "Randomly adding on cells to array of cells to degrade");
   for (int tab = 0; tab < kNumTabs; tab++) {
      for (int row = 0; row < SharedState::getInstance()->getTotalRows(); row++) {
         for (int col = 0; col < SharedState::getInstance()->getTotalCols(); col++) {
            Cell* cell = getCellAt(tab, row, col);
            if (cell->isOn()) {
               int index = random->nextInt(cellsToDegrade.size() + 1);
               DBG (String(Time::currentTimeMillis()) + " " + "Adding cell at tab" + String(tab) + "/row" + String(row) + "/col" + String(col) + " to index " + String(index));
               cellsToDegrade.insert(index, cell);
            }
         }
      }
   }
   DBG(String(Time::currentTimeMillis()) + " " + "Number of cells to degrade: " + String(cellsToDegrade.size()));

   timeStartDegradeMs = Time::currentTimeMillis();
   timeDegradeStepMs = Time::currentTimeMillis();

   setState(DEGRADING_SLOW);
}

void Panel::degradeStep()
{
   DBG(String(Time::currentTimeMillis()) + " " + "Panel::degradeStep()");

   jassert(isDegrading());

   int64 now = Time::currentTimeMillis();
   bool degradedSome = false;
   if (state == DEGRADING_SLOW) {
      // in slow mode, one at a time
      if (now - timeDegradeStepMs >= SharedState::kDegradeSlowSecPerDelete * 1000) {
         degradeOne();
         degradedSome = true;
      } else if (now - timeStartDegradeMs >= SharedState::kDegradeSlowSec * 1000) {
         // but first, degrade one
         degradeOne();
         degradedSome = true;
         // switch to fast mode
         setState(DEGRADING_FAST);
         // could be <1, in which case we really have delete per sec
         fastSecPerDelete = jmin((float)SharedState::kDegradeSlowSecPerDelete,
                                 (float)SharedState::kDegradeFastSec / (float)cellsToDegrade.size());
         DBG(String(Time::currentTimeMillis()) + " " + "Set fastSecPerDelete to " + String(fastSecPerDelete));
      }
   } else {
      // DEGRADING_FAST
      // delete based on the previously decided rate
      int toDelete = int((now - timeDegradeStepMs) / (fastSecPerDelete * 1000));
      if (toDelete > 0) {
         for (int i = 0; i < toDelete; i++) {
            degradeOne();
            degradedSome = true;
         }
      }
   }
   if (degradedSome) {
      timeDegradeStepMs = now;
   }
}

void Panel::degradeOne() {
   if (cellsToDegrade.size() > 0) {
      Cell* toDegrade = cellsToDegrade.getFirst();
      DBG(String(Time::currentTimeMillis()) + " " + "Degrading cell at row/" + String(toDegrade->getRow()) + " col/" + String(toDegrade->getCol()) + " (tab unknown)");
      toDegrade->setNoteOff();
      cellsToDegrade.remove(0);
   }
   if (cellsToDegrade.size() == 0) {
      DBG(String(Time::currentTimeMillis()) + " " + "Panel should be fully degraded");
      // but let's make sure
      for (int tab = 0; tab < kNumTabs; tab++) {
         for (int row = 0; row < SharedState::getInstance()->getTotalRows(); row++) {
            for (int col = 0; col < SharedState::getInstance()->getTotalCols(); col++) {
               Cell* cell = getCellAt(tab, row, col);
               if (cell->isOn()) {
                  DBG (String(Time::currentTimeMillis()) + " " + "WARNING: Found cell on when we expected full degradation at tab" + String(tab) + "/row" + String(row) + "/col" + String(col));
                  cell->setNoteOff();
               }
            }
         }
      }
      setState(DEGRADED);
   }
}

void Panel::stopDegrade()
{
   DBG(String(Time::currentTimeMillis()) + " " + "Stop degrading panel");
   cellsToDegrade.clear();
}

bool Panel::isDegrading()
{
   return (state == DEGRADING_SLOW ||
           state == DEGRADING_FAST);
}
