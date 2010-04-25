
/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/*  
  (c) copyright 2010 Inkstone Sound
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
 */

/**
 * Life player (conway & other life-like rules) for Syzygryd sequencer
 *
 * @author Simran Gleason
 */

import syzygryd.*;

public class Life {
    Button[][][] buttonSets;
    int[][] newValues;
    int numPanels;
    int gridWidth;
    int gridHeight;
    LifeRule rule;
    int numChangesThisRound;

    
    public Life(int numPanels,
                SequencerPanel[] panels,
                int gridWidth, int gridHeight,
                LifeRule rule) {
       
        this.numPanels = numPanels;
        this.gridWidth = gridWidth;
        this.gridHeight = gridHeight;
        this.rule = rule;
        buttonSets = new SequencerButton[numPanels][gridWidth][gridHeight];
        for(int p=0; p < numPanels; p++) {
            Button[][] panelButtons = (Button[][]) ((SequencerPatternTab) panels[p].selectedTab).buttons;
            for(int i=0; i < gridWidth; i++) {
              for(int j=0; j < gridHeight; j++) {
                buttonSets[p][i][j] = panelButtons[i][j];
              }
            }
        }
        newValues = new int[numPanels * gridWidth][gridHeight];
    }

    void oneStep() {
        numChangesThisRound = 0;
        for (int p = 0; p < numPanels; p++) {
            for(int i=0; i < gridWidth; i++) {
                for (int j=0; j < gridHeight; j++) {
                    int pi = gridWidth * p + i;
                    ToggleButton tb = (ToggleButton)buttonSets[p][i][j];
                    //println("["+p+"]["+i+"]["+j+"]...");
                    int currentValue = (tb.isOn ? 1 : 0);
                    newValues[pi][j] = rule.liveOrDie(currentValue,
                                                      numNeighborsOn(pi, j));
                    //println("        prev: " + currentValue + "        newVal[" + pi + "][" + j + "] ==== " + newValues[pi][j]);
                    if (newValues[pi][j] != 0) {
                        numChangesThisRound++;
                    }
                }
                //println();
            }
        }
        System.out.println("one step. numChanges: " + numChangesThisRound);
        //
        // Now set the values for cells that changed.
        //
        for (int p = 0; p < numPanels; p++) {
            for(int i=0; i < gridWidth; i++) {
                for (int j=0; j < gridHeight; j++) {
                    // only set the value of a button if its value changed in
                    // this round. 
                    int pi = p * gridWidth + i;
                    if (newValues[pi][j] != 0) {
                        float buttonValue = (newValues[pi][j] > 0 ? 1.0: 0.0);
                        SequencerButton seqB = (SequencerButton)buttonSets[p][i][j];
                        seqB.setValue(buttonValue);
                    }
                }
            }
        }
    }

    int numNeighborsOn(int pi, int j) {
        int piPlus1 = pi + 1;
        // implement toroidal playing space
        // with the panels lined up side-by-side
        //
        if (piPlus1 >= numPanels * gridWidth) {
            piPlus1 = 0;
        }
        int jPlus1 = j + 1;
        if (jPlus1 >= gridHeight) {
            jPlus1 = 0;
        }
        int piMinus1 = pi - 1;
        if (piMinus1 < 0) {
            piMinus1 = numPanels * gridWidth - 1;
        }
        int jMinus1 = j - 1;
        if (jMinus1 < 0) {
            jMinus1 = gridHeight - 1;
        }
        int nno = 
            getButtonValue(piMinus1, jMinus1) +
            getButtonValue(piMinus1, j) + 
            getButtonValue(piMinus1, jPlus1) +

            getButtonValue(pi, jMinus1) +
            getButtonValue(pi, jPlus1) +

            getButtonValue(piPlus1, jMinus1) +
            getButtonValue(piPlus1, j) + 
            getButtonValue(piPlus1, jPlus1);
       //System.out.println("        NNO[" + pi + "][" + j + "] ==> " + nno);
       return nno;
    }

    public int getButtonValue(int pi, int j) {
        int panel = (int)(pi / gridWidth);
        int i = pi - panel * gridWidth;
        //System.out.println("gbv: pi=" + pi + " panel=" + panel + " i=" + i + " j=" + j);
        ToggleButton tb = (ToggleButton)buttonSets[panel][i][j];
         boolean on = tb.isOn;
         //System.out.println("   gbv(" + pi + ", " + j + ") => " + tb + "    ON? " + on);
         //System.out.println("    gbv[" + pi + "][" + j + "] = [" + panel + "][" + i + "][" + j + "]  ==> " + on);
        return (on ? 1 : 0);
    }


}

