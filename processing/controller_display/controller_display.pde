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

import java.util.regex.Pattern;
import java.util.regex.Matcher;

// import com.apple.dnssd.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

/* Button Array for buttoning also tempo objects maybe more*/
DrawablePanel[] panels;
DrawablePanel selectedPanel;
Temposweep temposweep;
LinkedList animations = new LinkedList();

/* Sets an initial Hue for colors to cycle from. Changes almost immediately */
int masterHue = 1;

/* Last Pressable object selected by the user. */
Pressable lastSelectedPressable;

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

void setup() {
  // controller display can be made to grab the screen's current
  // resolution and apply it to the sketch, but for development
  // purposes we just smash to 1280x720
  // size(screen.width,screen.height,OPENGL);
  size(1280,720);
  smooth();
  //hide the mouse cursor (if not on touchscreen comment out!)
  //noCursor();

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

  syncCount = 0;

  // start oscP5, listening for incoming messages at port 9000
  oscP5 = new OscP5(this, 9000);

  // myRemoteLocation is set to the address and port the sequencer
  // listens on
  // TOUCHSCREEN!
  // for the touchscreen, change the localhost to whatever the fuck 
  // the ip address is for the sequencer machine
  myRemoteLocation = new NetAddress("localhost", 8000);

  // Connect to the server
  OscMessage connect = new OscMessage("/server/connect");
  System.out.println("Sending OSC message " + connect.addrPattern() + " to " + myRemoteLocation);
  oscP5.send(connect, myRemoteLocation);

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
  for (int i = 0; i < panels.length; i++) {
    panels[i] = new DrawablePanel(i, panels, numTabs, gridWidth, gridHeight, buttonSize, buttonSpacing);
  }
  selectPanel(0);
  temposweep = new Temposweep(buttonSize, buttonSpacing);
  
  scrollablemessage = new ScrollableMessage();
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
//   System.out.println(sb.toString());
// }

void oscEvent(OscMessage m) {
  try {
    // if(!m.addrPattern().endsWith("/tempo")) {
    //   println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
    //   m.print();
    // }

    // if (m.isPlugged()) {
    //   System.out.println("Not handling osc msg here b/c it is plugged: " + m.addrPattern());
    //   return;
    // }

    if (m.addrPattern().endsWith("/sync")) {
      syncCount++;
      if (syncSkip == 0 || syncCount >= syncSkip) {
        //System.out.println("Processing /sync: (count=" + syncCount + " skip=" + syncSkip + ")");
        syncCount = 0;
        int panelIndex = m.get(0).intValue();
        int curTab = m.get(1).intValue();	// XXX not used?
        int numTabs = m.get(2).intValue();
        int numRows = m.get(3).intValue();
        int numCols = m.get(4).intValue();
        int blobSize = m.get(5).intValue();	// XXX possibly get rid of this
        byte[] blob = m.get(6).blobValue();
        if (blob == null) {
          System.err.println("WARNING: null blob");
          return;
        }
        if (blob.length != blobSize) {
          System.err.println("WARNING: Size of blob (" + blob.length + ") does not match expected (" + blobSize + ")");
        }
        
        DrawablePanel panel = panels[panelIndex];
        
        int index = 0;
        for (int i = 0; i < numTabs; i++) {
          for (int j = 0; j < numRows; j++) {
            for (int k = 0; k < numCols; k++) {
              int byteSel = index / 8;
              int bitSel = index % 8;
              index++;
              
              boolean isOn = (blob[byteSel] & (1 << (7 - bitSel))) != 0;
              DrawableTab myTab = (DrawableTab) panel.tabs[i];
              DrawableButton myButton = (DrawableButton) myTab.buttons[k][j];
              if (isOn != myButton.isOn) {
                // In most cases, if the sync state differs from the button
                // state, we will trust the sync.  The exception is if we
                // explicitly decided to send out a particular button state in
                // the past (e.g. the button was pressed in the UI on this
                // panel) but this button press has not yet been confirmed in
                // a subsequent sync message.  In this case, we assume that
                // the previous OSC message that was sent was lost.  In that
                // case, we respond by resending the message.
                if (!myButton.isDirty) {
                  System.out.println("Changing state of panel:" + panelIndex + " tab:" + i + " row:" + j + " col:" + k
                                     + " " + myButton.isOn + "=>" + isOn);
                  float f_isOn =  isOn ? 1.0f : 0.0f;
                  myButton.setValue(f_isOn, false);
                } else {
                  System.out.println("Assuming lost OSC message, resending for panel:" + panelIndex + " tab:" + i + " row:" + j + " col:" + k
                                     + " " + myButton.isOn);
                  float f_isOn = myButton.isOn ? 1.0f : 0.0f;
                  myButton.setValue(f_isOn, true);
                }
              } else {
                myButton.isDirty = false;
              }
            }
          }
        }
      }
      // else {
      //   System.out.println("Skipping /sync: (count=" + syncCount + " skip=" + syncSkip + ")");
      // }
      return;
    } 

    /* check if the typetag is the right one. */
    if (m.checkTypetag("")) {
      // XXX do we really need to be parsing one of these, but not the other?
      // do we need both?  or can we get away with neither?

      // XXX afaict, commenting this out has no ill effects
      // /1_tab2
      Matcher tabSelectMatcher = tabSelectPattern.matcher(m.addrPattern());
      if (tabSelectMatcher.matches()) {
        try {
          int panelOscIndex = Integer.parseInt(tabSelectMatcher.group(1));
          int panelIndex = panelOscIndex - 1;
          int tabOscIndex = Integer.parseInt(tabSelectMatcher.group(2));
          int tabIndex = tabOscIndex - 1;
          System.out.println("Selecting tab " + tabIndex + " for panel " + panelIndex + " based on osc message: " + m.addrPattern());
          panels[panelIndex].selectTab(tabIndex);
        } catch (NumberFormatException nfe) {
          System.err.println("WARNING: Unable to parse tab select OSC message: " + m.addrPattern());
        }
        return;
      }

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
      //     System.out.println("Clear button pressed for tab " + tabIndex + " for panel " + panelIndex + ", but so what???: " + m.addrPattern());
      //   } catch (NumberFormatException nfe) {
      //     System.err.println("WARNING: Unable to parse tab clear OSC message: " + m.addrPattern());
      //   }
      //   return;
      // }

      // otherwise, ignore

    } else if (m.checkTypetag("f")) {
      if (m.addrPattern().endsWith("/tempo")) {
        float firstValue = m.get(0).floatValue();
        float v = (firstValue - 0.03125) * 16;
        temposweep.setValue(int(v));
      }

      // otherwise, ignore
    }
  } catch (Exception e) {
    System.err.println("WARNING: Exception caught while processing OSC message: " + m.addrPattern());
    e.printStackTrace();
  }
}

  // TOUCHSCREEN!
  // For the touchscreen, change mouseClicked() to mousePressed()
void mouseClicked() {
  Pressable p = ((DrawableTab) selectedPanel.selectedTab).getButtonFromMouseCoords(mouseX, mouseY);
  if (p != null) {
    p.press();
  }
}

void mouseReleased() {
  lastSelectedPressable = null;
}

void mouseDragged() {
  Pressable p = ((DrawableTab) selectedPanel.selectedTab).getButtonFromMouseCoords(mouseX, mouseY);
  if ((p != lastSelectedPressable) &&
      (p != null)) {
    p.press();
    lastSelectedPressable = p;
  }
}

void keyPressed() {
  if (key == '1') {
    selectPanel(0);
  } else if (key == '2') {
    selectPanel(1);
  } else if (key == '3') {
    selectPanel(2);
  } else if (key == 'q') {
    exit(); 
  }
}
