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

Panel::Panel (int totalRows_, int totalCols_, int panelIndex_) :
panelIndex (panelIndex_),
tabIndex (0),
lastTouchMs (Time::currentTimeMillis()),
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
   //DBG(String(Time::currentTimeMillis()) + " " + "Panel::updateStarField()");
   // only update the active tab with a star field, not all of the tabs
	/*
	for (int i = 0; i < kNumTabs; i++) {
		Tab* tab = tabs[i];
		tab->updateStarField();
	}
	 */
	tabs[tabIndex]->updateStarField();
}

void Panel::skipIntoStarField()
{
	tabs[tabIndex]->skipIntoStarField();
}

int64 Panel::getLastTouchElapsedMs()
{
   int64 now = Time::currentTimeMillis();

	return now - lastTouchMs;
}

// this should only be called if a panel is touched
// bug:67 - for properly coming out of attract mode, it is important that this is called *before* any other action on the touch is taken
void Panel::updateLastTouch(bool fromStopAttract_)
{
   int64 now = Time::currentTimeMillis();

   // DBG(String(now) + " "
   //     + "Setting lastTouchMs on panel " + String(panelIndex) + " to " + String(now) + " fromStopAttract=" + String(fromStopAttract_));

   // this is needed so that we don't get stuck in an endless loop
   if (!fromStopAttract_) {
      if (isAttracting()) {
#ifdef JUCE_DEBUG
         if (!SharedState::getInstance()->allAttracting()) {
            DBG(String(now) + " "
                + "WARNING: Panel " + String(panelIndex) + " is about to leave attract mode, but not all panels are in attract mode, which they should be");
         }
#endif
         DBG (String(now) + " "
              + "Panel " + String(panelIndex) + " has been touched, stopping attract on all panels");
         SharedState::getInstance()->stopAttract();
      } else if (isDegrading()) {
         stopDegrade();
      }
      setState(ACTIVE);
   }
	lastTouchMs = now;
}

void Panel::updateLastTouch()
{
   updateLastTouch(/* fromStopAttract */ false);
}

void Panel::setState(int state_)
{
   // XXX bug:67 - we could add code to verify the state transitions
#ifdef JUCE_DEBUG
   // XXX outputting a real string would be better
   if (state_ != state) {
      DBG(String(Time::currentTimeMillis()) + " "
          + "Changing state on panel " + String(panelIndex) + " from " + String(state) + " to " + String(state_));
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
   DBG(String(Time::currentTimeMillis()) + " "
       + "Start degrading panel " + String(panelIndex));
   jassert(state == ACTIVE);

   // go through all of the cells that are on, and randomly insert them into
   // an array.  this will be the array that we will go through in order for
   // degrading.
   // should already be empty, but just in case
   cellsToDegrade.clear();
   DBG(String(Time::currentTimeMillis()) + " "
       + "Randomly adding ON cells to array of cells to degrade for panel " + String(panelIndex));
   for (int tab = 0; tab < kNumTabs; tab++) {
      for (int row = 0; row < SharedState::getInstance()->getTotalRows(); row++) {
         for (int col = 0; col < SharedState::getInstance()->getTotalCols(); col++) {
            Cell* cell = getCellAt(tab, row, col);
            if (cell->isOn()) {
               int index = random->nextInt(cellsToDegrade.size() + 1);
               // DBG (String(Time::currentTimeMillis()) + " "
               //      + "Adding cell on panel" + String(panelIndex) + " at tab" + String(tab) + "/row" + String(row) + "/col" + String(col) + " to index " + String(index));
               cellsToDegrade.insert(index, cell);
            }
         }
      }
   }
   DBG(String(Time::currentTimeMillis()) + " "
       + "Number of cells to degrade for panel " + String(panelIndex) + ": " + String(cellsToDegrade.size()));

   timeStartDegradeMs = Time::currentTimeMillis();
   timeDegradeStepMs = Time::currentTimeMillis();

   setState(DEGRADING_SLOW);
}

void Panel::degradeStep()
{
   //DBG(String(Time::currentTimeMillis()) + " " + "Panel::degradeStep() for panel " + String(panelIndex));

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
         DBG(String(Time::currentTimeMillis()) + " "
             + "Set fastSecPerDelete to " + String(fastSecPerDelete) + " for panel " + String(panelIndex));
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
      // DBG(String(Time::currentTimeMillis()) + " "
      //     + "Degrading cell on panel/" + String(panelIndex) + " tab/" + String(tabIndex) + " at row/" + String(toDegrade->getRow()) + " col/" + String(toDegrade->getCol()));
      toDegrade->setNoteOff();
      cellsToDegrade.remove(0);
   }
   if (cellsToDegrade.size() == 0) {
      DBG(String(Time::currentTimeMillis()) + " "
          + "Panel " + String(panelIndex) + " should be fully degraded");
      // but let's make sure
      for (int tab = 0; tab < kNumTabs; tab++) {
         for (int row = 0; row < SharedState::getInstance()->getTotalRows(); row++) {
            for (int col = 0; col < SharedState::getInstance()->getTotalCols(); col++) {
               Cell* cell = getCellAt(tab, row, col);
               if (cell->isOn()) {
                  DBG (String(Time::currentTimeMillis()) + " "
                       + "WARNING: Found cell on when we expected full degradation on panel/" + String(panelIndex) + " at tab" + String(tab) + "/row" + String(row) + "/col" + String(col));
                  cell->setNoteOff();
               }
            }
         }
      }
      setState(DEGRADED);
      // set all panels to ATTRACT iff. they are all DEGRADED
      if (SharedState::getInstance()->allDegraded()) {
         DBG (String(Time::currentTimeMillis()) + " "
              + "All panels are degraded (ending with panel " + String(panelIndex) + ", starting attract");
         SharedState::getInstance()->startAttract();
      }
   }
}

void Panel::stopDegrade()
{
   DBG(String(Time::currentTimeMillis()) + " "
       + "Stop degrading panel " + String(panelIndex));
   cellsToDegrade.clear();
}

bool Panel::isDegrading()
{
   return (state == DEGRADING_SLOW ||
           state == DEGRADING_FAST);
}

bool Panel::isAttracting()
{
   return state == ATTRACT;
}
