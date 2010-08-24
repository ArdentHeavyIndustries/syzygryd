/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Project PKM Display Layer
 * Displays a controller, which sends and receives OSC to/from Sequencer
 */

import syzygryd.*;
import processing.opengl.*;

/* Osc business */
import oscP5.*;
import netP5.*;

import java.util.Calendar;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

// Used for debugging
//PrintWriter output; 

OscP5 oscP5;
NetAddress myRemoteLocation;
int lastEventReceived = millis();
final int OSC_WATCHDOG_SEC = 10;

/* Button Array for buttoning also tempo objects maybe more*/
DrawablePanel[] panels;
DrawablePanel selectedPanel;
Temposweep temposweep;
LinkedList animations = new LinkedList();

/* Sets an initial Hue for panel colors. Lighting can change this. */
/* Hues are in the range [0-100] (see colorMode() below) */
int[] masterHues;

// Uncomment re-implement dragging.
/* Last Pressable object selected by the user. */
// Pressable lastSelectedPressable;

//Font for messages at the bottom of the display
PFont msgFont;
ScrollableMessage scrollablemessage;

// Button SVG graphics.  We use the same graphic for all the buttons,
// which only needs to be loaded once.  Since Processing doesn't have
// static vars these are globals.
PShape masterButton, left, right, middle, middleOnSweep;

Pattern tabSelectPattern =
  Pattern.compile("/(\\d+)_tab(\\d+)");
// XXX this is not currently used
Pattern tabClearPattern =
  Pattern.compile("/(\\d+)_control/clear/tab(\\d+)");                  

// set this if we decide that it's too much overhead to process every sync
// message and we want to skip some.  we process every N sync messages if this
// is set to > 0.  e.g. 2 means every other message, 1 means every message.
// set to 0 to disable.  (so 1 is effectively the same as 0)
final int syncSkip = 0;
int syncCount;

// i think it's probably more correct to initialize this to true, and wait for
// confirmation that a set is running.  but i don't see too much of a downside
// of initializing it to false, and it certainly makes it easier to run small
// scale tests.  in the worst case, we think we're running during the first
// set switching.
boolean setStopped = false;

final int OSC_LISTENING_PORT = 9002;
final int OSC_SENDING_PORT = 8000;

void setup() {
  // controller display can be made to grab the screen's current
  // resolution and apply it to the sketch, but for development
  // purposes we just smash to 1280x720
  // size(screen.width,screen.height,OPENGL);
  // normal computer
  //size(1280,720);
  // touchscreen
  size(1366,768);
  smooth();
  //hide the mouse cursor (if not on touchscreen comment out!)
  //noCursor();

  // Used for debugging
//  output = createWriter("debug.txt");
  
  // changing color mode to hsb for ease of getting at the color wheel.
  colorMode(HSB, 100); 
  
    //a quicker way to do the above without an if statement
  int buttonSize = ((height)/22) << 1;
  
  //load up shape
  masterButton = loadShape("button3.svg");

  //let's make some buttons yo!
  // somehow scale acts differently here than in drawablebutton, thus
  // why the extra 0.006 needed (processing.org built their own SVG
  // implementation) 
  // that said, in the code the undocumented call resetMatrix() fixes
  // scaling issues below 1
  float scaleFactor = (buttonSize/masterButton.width);
  left = masterButton.getChild("left");
  left.resetMatrix();
  left.scale(scaleFactor);
  right = masterButton.getChild("right");
  right.resetMatrix();
  right.scale(scaleFactor);
  middle = masterButton.getChild("middle");
  middle.resetMatrix();
  middle.scale(scaleFactor);
  middleOnSweep = masterButton.getChild("middleOn");
  //scale this one differently for cool effect
  middleOnSweep.resetMatrix();
  middleOnSweep.scale(scaleFactor*0.9);

  //int buttonSize = height / 11; // size of button based on real estate
  // Force button to be an even size so the active light can be
  // properly centered
  //if (buttonSize % 2 == 1) {
  //  buttonSize--;
  //}
  
  int buttonSpacing = buttonSize + 4; // spacing btwn buttons based on buttonSize
 
  int gridWidth = 16;
  int gridHeight = 10;
  int numPanels = 3;
  int numTabs = 4;

  panels = new DrawablePanel[numPanels];
  masterHues = new int[numPanels];
  for (int i = 0; i < panels.length; i++) {
    // initialize to even distributions in the range 0-100
    masterHues[i] = (i * 100) / panels.length;
    panels[i] = new DrawablePanel(i, panels, numTabs, gridWidth, gridHeight, buttonSize, buttonSpacing);
  }
  selectPanel(0);
  temposweep = new Temposweep(buttonSize, buttonSpacing);
  
  scrollablemessage = new ScrollableMessage();

  syncCount = 0;

  // start oscP5, listening for incoming messages
  startOsc();

  // myRemoteLocation is set to the address and port the sequencer
  // listens on
  // TOUCHSCREEN!
  // for the touchscreen, change the localhost to whatever the fuck 
  // the ip address is for the sequencer machine
  // XXX in the long term, why don't we just sensibly choose ports so that there aren't conflicts and send to the broadcast address?
  // local testing
  //myRemoteLocation = new NetAddress("localhost", OSC_SENDING_PORT);
  // this is the syzyputer.  DON'T FUCK WITH IT NOW.
  myRemoteLocation = new NetAddress("10.10.10.10", OSC_SENDING_PORT);

  // Connect to the server
  // OscMessage connect = new OscMessage("/server/connect");
  // log("Sending OSC message " + connect.addrPattern() + " to " + myRemoteLocation);
  // oscP5.send(connect, myRemoteLocation);
}

int curSecond = 0;

void draw() {
  background(0);

  for (ListIterator i = animations.listIterator(0); i.hasNext(); ) {
    Animation a = (Animation) i.next();
    a.step();
    if (!a.active) {
      i.remove();
    }
  }

  selectedPanel.draw();
  temposweep.draw();
  scrollablemessage.msgDraw();

  if (millis() - lastEventReceived > OSC_WATCHDOG_SEC * 1000) {
    // Looks like someone quit Live.  Reinitialize OscP5
    restartOsc();
  }
}

void selectPanel(int id) {
  selectedPanel = panels[id];
}

// useful for debugging sync msgs
// void outputByteArray(byte[] bytes) {
//   StringBuffer sb = new StringBuffer();
//   for (int i = 0; i < bytes.length; i++) {
//     sb.append(Integer.toHexString((int)bytes[i] & 0xF));
//     if (i % 2 == 1) {
//       sb.append(" ");
//     }
//     if (i % 16 == 15) {
//       sb.append("\n");
//     }
//   }
//   log(sb.toString());
// }

void oscEvent(OscMessage m) {
  lastEventReceived = millis();

  try {
    // if(!m.addrPattern().endsWith("/sync")) {
    //   log("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
    //   m.print();
    // }

    // if (m.isPlugged()) {
    //   log("Not handling osc msg here b/c it is plugged: " + m.addrPattern());
    //   return;
    // }

    if (m.addrPattern().equals("/sync")) {
      if (setStopped) {
        //log("Ignorning sync msg because set is stopped");
        return;
      }
      syncCount++;
      if (syncSkip == 0 || syncCount >= syncSkip) {
        //log("Processing /sync: (count=" + syncCount + " skip=" + syncSkip + ")");
        syncCount = 0;

        float playheadColPrecise = m.get(0).floatValue();
        double ppqPosition = m.get(1).doubleValue(); // XXX not currently used
        double timeInSeconds = m.get(2).doubleValue(); // XXX not currently used
        double bpm = m.get(3).doubleValue(); // XXX not currently used
        int panelIndex = m.get(4).intValue();
        int curTab = m.get(5).intValue();
        int numTabs = m.get(6).intValue();
        int numRows = m.get(7).intValue();
        int numCols = m.get(8).intValue();
        //log("sync: playheadColPrecise="+playheadColPrecise+" ppqPosition="+ppqPosition+" timeInSeconds="+timeInSeconds+" bpm="+bpm+" panelIndex="+panelIndex+" curTab="+curTab+" numTabs="+numTabs+" numRows="+numRows+" numCols="+numCols);

        if (playheadColPrecise >= 0.0f && playheadColPrecise < 16.0f) {
          int playheadCol = int(playheadColPrecise);
          temposweep.setValue(playheadCol);
        } else {
          warn("Unexpected playheadColPrecise: " + playheadColPrecise);
        }

        if (curTab != panels[panelIndex].selectedTab.id) {
          log("Changing tab for panel " + panelIndex + ": " + panels[panelIndex].selectedTab.id + " => " + curTab);
          panels[panelIndex].selectTab(curTab);
        }

        byte[] blob = m.get(9).blobValue();
        //outputByteArray(blob);
        if (blob == null) {
          warn("null blob");
          return;
        }

        DrawablePanel panel = panels[panelIndex];

        if (numTabs > panel.tabs.length) {
          warn("number of tabs in /sync msg (" + numTabs + ") > expected (" + panel.tabs.length + ")");
          return;
        }
        
        int index = 0;
        for (int i = 0; i < numTabs; i++) {
          DrawableTab myTab = (DrawableTab) panel.tabs[i];
          if (numCols > myTab.buttons.length) {
            warn("number of columns in /sync msg (" + numCols + ") > expected (" + myTab.buttons.length + ")");
            return;
          }
          for (int j = 0; j < numRows; j++) {
            for (int k = 0; k < numCols; k++) {
              int byteSel = index / 8;
              int bitSel = index % 8;
              index++;
              
              boolean isOn = (blob[byteSel] & (1 << (7 - bitSel))) != 0;
              if (numRows > myTab.buttons[k].length) {
                warn("number of rows in /sync msg (" + numRows + ") > expected (" + myTab.buttons[k].length + ")");
                return;
              }
              DrawableButton myButton = (DrawableButton) myTab.buttons[k][j];
              if (isOn != myButton.isOn) {
                // XXX no, we're going to trust the sync always
                // In most cases, if the sync state differs from the button
                // state, we will trust the sync.  The exception is if we
                // explicitly decided to send out a particular button state in
                // the past (e.g. the button was pressed in the UI on this
                // panel) but this button press has not yet been confirmed in
                // a subsequent sync message.  In this case, we assume that
                // the previous OSC message that was sent was lost.  In that
                // case, we respond by resending the message.
                // if (!myButton.isDirty) {
                  // log("Changing state of panel:" + panelIndex + " tab:" + i + " row:" + j + " col:" + k
                  //     + " " + myButton.isOn + "=>" + isOn);
                  float f_isOn =  isOn ? 1.0f : 0.0f;
                  // This actually changes the button's state in the
                  // controller, which was not done earlier when the button
                  // was actually pressed.  See comments in
                  // DrawableButton.setValue() for more details.
                  myButton.setValue(f_isOn, /* sendMessage */ false);
                // } else {
                //   log("Assuming lost OSC message, resending for panel:" + panelIndex + " tab:" + i + " row:" + j + " col:" + k
                //       + " " + myButton.isOn);
                //   float f_isOn = myButton.isOn ? 1.0f : 0.0f;
                //   myButton.setValue(f_isOn, true);
                // }
              // } else {
              //   myButton.isDirty = false;
              }
            }
          }
        }
      }
      // else {
      //   log("Skipping /sync: (count=" + syncCount + " skip=" + syncSkip + ")");
      // }
      return;
    } 

    // colors are in the form ARGB, converted to hue, then scaled
    if (m.addrPattern().equals("/color")) {
      for (int i = 0; i < panels.length; i++) {
        color c = m.get(i).intValue();
        masterHues[i] = (int)hue(c);
        log("Setting panel " + i + " to hue " + masterHues[i] + " based on color 0x" + hex(c));
      }
      return;
    }

    if (m.addrPattern().equals("/timeRemaining")) {
      int timeRemainingMs = m.get(0).intValue();
      log("Time remaining in set: " + timeRemainingMs + " ms");
      if (timeRemainingMs > 0 && setStopped) {
        startSet();
      } else if (timeRemainingMs <= 0 && !setStopped) {
        stopSet();
      }
    }

    /* check if the typetag is the right one. */
    // if (m.checkTypetag("")) {
      // XXX do we really need to be parsing one of these, but not the other?
      // do we need both?  or can we get away with neither?

      // XXX afaict, commenting this out has no ill effects
      // /1_tab2
      // Matcher tabSelectMatcher = tabSelectPattern.matcher(m.addrPattern());
      // if (tabSelectMatcher.matches()) {
      //   try {
      //     int panelOscIndex = Integer.parseInt(tabSelectMatcher.group(1));
      //     int panelIndex = panelOscIndex - 1;
      //     int tabOscIndex = Integer.parseInt(tabSelectMatcher.group(2));
      //     int tabIndex = tabOscIndex - 1;
      //     log("Selecting tab " + tabIndex + " for panel " + panelIndex + " based on osc message: " + m.addrPattern());
      //     panels[panelIndex].selectTab(tabIndex);
      //   } catch (NumberFormatException nfe) {
      //     warn("Unable to parse tab select OSC message: " + m.addrPattern());
      //   }
      //   return;
      // }

      // XXX comment out for now b/c this isn't doing anything
      // // /1_control/clear/tab2
      // Matcher tabClearMatcher = tabClearPattern.matcher(m.addrPattern());
      // if (tabClearMatcher.matches()) {
      //   try {
      //     int panelOscIndex = Integer.parseInt(tabClearMatcher.group(1));
      //     int panelIndex = panelOscIndex - 1;
      //     int tabOscIndex = Integer.parseInt(tabClearMatcher.group(2));
      //     int tabIndex = tabOscIndex - 1;
      //     // XXX but now what ???
      //     log("Clear button pressed for tab " + tabIndex + " for panel " + panelIndex + ", but so what???: " + m.addrPattern());
      //   } catch (NumberFormatException nfe) {
      //     warn("Unable to parse tab clear OSC message: " + m.addrPattern());
      //   }
      //   return;
      // }

      // otherwise, ignore
    // }
  } catch (Exception e) {
    warn("Exception caught while processing OSC message: " + m.addrPattern());
    e.printStackTrace();
  }
}

void startSet() {
  log("Starting set");

  // this deals with the svn r569 (nobug) issue, just in case the timing of the restart on stopSet() is timed wrong wrt the Live restart due to a race condition
  restartOsc();

  setStopped = false;
}

void stopSet() {
  log("Stopping set");
  setStopped = true;

  // a smooth transition of buttons going away would be nicer
  for (int i = 0; i < panels.length; i++) {
    DrawablePanel panel = panels[i];
    for (int j = 0; j < panel.tabs.length; j++) {
      DrawableTab tab = (DrawableTab)panel.tabs[j];
      // the first clear is to send a message to the sequencer for it to clear its state
      // the second clear is to actually clear our internal state
      // we can't count on getting the echo from the sequencer, b/c we've set setStopped and are therefore ignoring sync msgs
      // and button transitions behave differently depending on whether or not a msg is being sent to the weird nature of our architecture
      tab.clear(/* sendMessage */ true);
      tab.clear(/* sendMessage */ false);
    }
  }

  restartOsc();
}

void restartOsc() {
  log("Restarting osc");
  stopOsc();
  startOsc();
}

void stopOsc() {
  oscP5.dispose();
}

void startOsc() {
  oscP5 = new OscP5(this, OSC_LISTENING_PORT);
  lastEventReceived = millis();
}

// TOUCHSCREEN!
// For the touchscreen, change mouseClicked() to mousePressed()
// bug:63 i'm not sure if i agree with the above statement.  always use mousePressed() for now.
void mousePressed() {
  //log("mousePressed()");
  if (!setStopped) {
    Pressable p = ((DrawableTab) selectedPanel.selectedTab).getButtonFromMouseCoords(mouseX, mouseY);
    if (p != null) {
      p.press();
    }
  }
}

// void mouseClicked() {
//   log("mouseClicked()");
// }

// Uncomment mouseReleased() to re-implement dragging.
// void mouseReleased() {
//   //log("mouseReleased()");
//   lastSelectedPressable = null;
// }

// Uncomment mouseDragged() to re-implement dragging.
// void mouseDragged() {
//   log("mouseDragged()");
//  Pressable p = ((DrawableTab) selectedPanel.selectedTab).getButtonFromMouseCoords(mouseX, mouseY);
//  if ((p != lastSelectedPressable) &&
//      (p != null)) {
//    p.press();
//    lastSelectedPressable = p;
//  }
// }

void keyPressed() {
  if (key == '1') {
    selectPanel(0);
  } else if (key == '2') {
    selectPanel(1);
  } else if (key == '3') {
    selectPanel(2);
  } else if (key == 'q') {
//    output.flush(); // Writes the remaining data to the file
//    output.close(); // Finishes the file    
   exit(); 
  }
}

// for debugging.  log statements should be commented out for a production build.  warnings can probably stay.

// pad a string to at least a minimum size by prepending the given char
// the StringBuffer is modified in place
void prefixPad(StringBuffer sb, int minsize, char c) {
  int toAdd = minsize - sb.length();
  if (toAdd > 0) {
    for (int i = 0; i < toAdd; i++) {
      sb.insert(0, c);
    }
  }
}

String getTime() {
  Calendar cal = Calendar.getInstance();

  StringBuffer year = new StringBuffer();
  year.append(cal.get(Calendar.YEAR));
  prefixPad(year, 4, '0');
  StringBuffer month = new StringBuffer();
  month.append(cal.get(Calendar.MONTH) + 1);
  prefixPad(month, 2, '0');
  StringBuffer day = new StringBuffer();
  day.append(cal.get(Calendar.DAY_OF_MONTH));
  prefixPad(day, 2, '0');
  StringBuffer hour = new StringBuffer();
  hour.append(cal.get(Calendar.HOUR_OF_DAY));
  prefixPad(hour, 2, '0');
  StringBuffer min = new StringBuffer();
  min.append(cal.get(Calendar.MINUTE));
  prefixPad(min, 2, '0');
  StringBuffer sec = new StringBuffer();
  sec.append(cal.get(Calendar.SECOND));
  prefixPad(sec, 2, '0');
  StringBuffer millis = new StringBuffer();
  millis.append(cal.get(Calendar.MILLISECOND));
  prefixPad(millis, 3, '0');

  StringBuffer date = new StringBuffer();
  date.append('[');
  date.append(year);
  date.append('/');
  date.append(month);
  date.append('/');
  date.append(day);
  date.append(' ');
  date.append(hour);
  date.append(':');
  date.append(min);
  date.append(':');
  date.append(sec);
  date.append('.');
  date.append(millis);
  date.append(']');

  return date.toString();
}

// for production use, we should comment out all calls to log
// for now, comment out the contents here, unless you want verbose logging
void log(String msg) {
  //System.out.println(getTime() + " " + msg);
}

void warn(String msg) {
  System.err.println(getTime() + " WARNING: " + msg);
}
