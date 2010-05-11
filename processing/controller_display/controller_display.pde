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
import processing.opengl.*;

// import com.apple.dnssd.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

/* Button Array for buttoning also tempo objects maybe more*/
HashMap objectMapOSC = new HashMap();
DrawablePanel[] panels;
DrawablePanel selectedPanel;
Temposweep temposweep;
HashMap typeMapOSC = new HashMap();
Vector animations = new Vector(16);

/* Sets an initial Hue for colors to cycle from. Changes almost immediately */
int masterHue = 1;

/* Last Pressable object selected by the user. */
Pressable lastSelectedPressable;

boolean armClear = false;

void setup() {
  // TOUCHSCREEN!
  //change to 1920,1080 for the touchscreen!
  //for the touchscreen, make sure you 'present' instead of run, in the sketch menu.
  size(1280,720, OPENGL);// 16:9 window
  
  /* dunno why there's a framerate specified, there usually isn't, 
   * but all the osc examples had one. */
  frameRate(30); 

  // changing color mode to hsb for ease of getting at the color wheel.
  colorMode(HSB, 100); 

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
  oscP5.send(connect, myRemoteLocation);

  int buttonSize = height / 11; // size of button based on real estate
  // Force button to be an even size so the active light can be
  // properly centered
  if (buttonSize % 2 == 1) {
    buttonSize--;
  }
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
}

int curSecond = 0;

void draw() {
  background(0);
  selectedPanel.draw();
  for (Enumeration e = animations.elements(); e.hasMoreElements(); ) {
    Animation a = (Animation) e.nextElement();
    a.step();
  }
  temposweep.draw();
}

void selectPanel(int id) {
  selectedPanel = panels[id];
}

void oscEvent(OscMessage m) {
  if(!m.addrPattern().endsWith("/tempo")) {
    // println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
    // m.print();
  }

  if (m.isPlugged()) {
    return;
  }

  /* check if the typetag is the right one. */
  if (m.checkTypetag("")) {
    String[] patternParts = m.addrPattern().split("/", -1);
    String[] panelAndTab = patternParts[1].split("_", -1);

    int panelOscIndex = new Integer(panelAndTab[0]).intValue();
    int panelIndex = panelOscIndex - 1;

    // FYI this is hacky and will break if we ever have more than 9 tabs
    int tabOscIndex = new Integer(panelAndTab[1].substring(panelAndTab[1].length() - 1));
    int tabIndex = tabOscIndex - 1;

    panels[panelIndex].selectTab(tabIndex);
  } else if (m.checkTypetag("f")) {
    float firstValue = m.get(0).floatValue();

    if (m.addrPattern().endsWith("/tempo")) {
      float v = (firstValue - 0.03125) * 16;
      temposweep.setValue(int(v));
    }
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
  }
}
