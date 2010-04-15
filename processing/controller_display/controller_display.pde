
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
HashMap buttonsByRow = new HashMap();

/* Sets an initial Hue for colors to cycle from. Changes almost immediately */
int masterHue = 1;

/* Last Pressable object selected by the user. */
Pressable lastSelectedPressable;

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

  int buttonCounter = 0;
  int buttonSize = height / 11; // size of button based on real estate
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

  /* FOO This is where the initialization code was */

  // Where should this go?  Should it go in to the Panel, Tab or
  // Button class?
  temposweep = new Temposweep(buttonSize, buttonSpacing, buttonsByRow);
  /*
  temposweep = new Temposweep(buttonSize, buttonSpacing, buttonsByRow);
  objectMapOSC.put ("/temposlider/step", temposweep);
  typeMapOSC.put ("/temposlider/step", "temposweep");
  */
}


int curSecond = 0;

void draw() {
  background (0);
  selectedPanel.draw();

  // TODO: Probably want to move temposweep object into the tabs...
  temposweep.draw();
}

void selectPanel(int id) {
  selectedPanel = panels[id];
}

void oscEvent(OscMessage m) {
  if(!m.addrPattern().endsWith("/tempo")) {
      println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
      // m.print();
  }

  /* check if m has the address pattern we are looking for. */
  if (!m.addrPattern().endsWith("/tempo")) {
    if(objectMapOSC == null || !objectMapOSC.containsKey(m.addrPattern())){
      return;
    }
  }

  /* check if the typetag is the right one. */
  if(m.checkTypetag("f")) {
    float firstValue = 0;
    /* parse m and extract the values from the osc message arguments. */
    //  println(m);
    //m.print();
    firstValue = m.get(0).floatValue();  
    // print("### received an osc message /test with typetag ifs.");


    if(typeMapOSC.get(m.addrPattern())=="button") {
      DrawableButton thisOSCObject = (DrawableButton) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(firstValue, false);
    } else if (m.addrPattern().endsWith("/tempo")) {
      float v = (firstValue - 0.03125) * 16;
      // println(v);
      temposweep.setValue(int(v));
    }
    /*
    } else if (typeMapOSC.get(m.addrPattern())=="temposweep") {
      Temposweep thisOSCObject = (Temposweep) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(int(firstValue));
    }
    */
  } else if(m.checkTypetag("i")) {
    int firstValue =0;
    /* parse m and extract the values from the osc message arguments. */
    //  println(m);
    //m.print();
    firstValue = m.get(0).intValue();  
    // print("### received an osc message /test with typetag ifs.");


    if(typeMapOSC.get(m.addrPattern())=="button") {
      DrawableButton thisOSCObject = (DrawableButton) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(float(firstValue), false);
    } 
    else if (typeMapOSC.get(m.addrPattern())=="temposweep") {
      Temposweep thisOSCObject = (Temposweep) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(firstValue);
    }
  }
  /* TODO: remove this debug
  println("### received an osc message. with address pattern "+m.addrPattern());
  */
}

  // TOUCHSCREEN!
  // For the touchscreen, change mouseClicked() to mousePressed()
void mouseClicked() {
  Pressable p = ((DrawableTab) selectedPanel.selectedTab).getButtonFromMouseCoords(mouseX, mouseY);
  if (p != null) {
    p.press();
  }
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
