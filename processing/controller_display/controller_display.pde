/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Project PKM Display Layer
 * Recieves osc from Max patch, displays it in a 16:9 window. 
 * Meant to go directly on tv screen eventually.
 */

/* Osc business */
import oscP5.*;
import netP5.*;
import processing.opengl.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

/* Button Array for buttoning also tempo objects maybe more*/
HashMap objectMapOSC = new HashMap();
Panel[] panels;
Panel selectedPanel;
Button[] buttons;
Temposweep temposweep;
HashMap typeMapOSC = new HashMap();
HashMap buttonsByRow = new HashMap();

/* A place to store active particle systems */
//ArrayList particleSystemsSimple;

/* Sets an initial Hue for colors to cycle from. Changes almost immediately */
int masterHue = 1;

void setup() {
  size(1280,720); // 16:9 window
  
//  particleSystemsSimple = new ArrayList();   // for storing particles
  
  /* dunno why there's a framerate specified, there usually isn't, 
   * but all the osc examples had one. */
  frameRate(30); 

  /* changing color mode to hsb for ease of getting at the color wheel. */
  colorMode(HSB, 100); 


  /* start oscP5, listening for incoming messages at port 8001
   * this isn't the port from touchosc, it's a port out of max.
   * max needs to  be set up to send out to this patch with a 
   * port different from the listen port for the controllers
   * if you're running it on the same machine. */
  oscP5 = new OscP5(this, 9000);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. Currently not used at all. 
   * Probably should route to Max rather than direct to controller.
   */
  myRemoteLocation = new NetAddress("localhost", 8000);

  // Connect to the server
  OscMessage connect = new OscMessage("/server/connect");
  oscP5.send(connect, myRemoteLocation);

  int buttonCounter = 0;
  int buttonSize = height/11; // size of button based on real estate
  int buttonSpacing = buttonSize+4; // spacing btwn buttons based on buttonSize

  int panelWidth = 16;
  int panelHeight = 10;
  int numPanels = 3;
  int numTabs = 4;

  panels = new Panel[numPanels];

  for (int i = 0; i < panels.length; i++) {
    panels[i] = new Panel(i, panels, panelWidth, panelHeight, numTabs, buttonSize, buttonSpacing);
  }
  selectPanel(0);

  /* FOO This is where the initialization code was */

  // Where should this go?  Should it go in to the Panel, Tab or
  // Button class?
  temposweep = new Temposweep(buttonSize, buttonSpacing, buttonsByRow);
  objectMapOSC.put ("/temposlider/step", temposweep);
  typeMapOSC.put ("/temposlider/step", "temposweep");
}


int curSecond = 0;

void draw() {

  background (0);
  selectedPanel.draw();
  /*
  for(int i = 0; i < buttons.length; i++){
    buttons[i].draw(false);
    buttons[i].setHue(masterHue);
  }
  */

  if(second() % 5 == 0 && second() != curSecond){ //does changing the modulo here make color cycle faster or slower?
    masterHue+=1;
    if(masterHue > 100){
      masterHue -=100; 
    }
    curSecond = second();
  }
  
  // TODO: reenable this
  // temposweep.draw();
  
  // Cycle through all particle systems, run them and delete old ones
/*  for (int i = particleSystemsSimple.size()-1; i >= 0; i--) {
    ParticleSystemSimple psys = (ParticleSystemSimple) particleSystemsSimple.get(i);
    psys.run();
    if (psys.dead()) {
      particleSystemsSimple.remove(i);
    }
  }
*/
  /*
  for(int i = 0; i < buttons.length; i++){
    buttons[i].draw(true);
  }
  */
}

void selectPanel(int id) {
  selectedPanel = panels[id];
}

void oscEvent(OscMessage m) {
  /* TODO: remove this debug code
  if(!m.addrPattern().endsWith("/tempo")) {
      println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
  }
  */
  /* check if m has the address pattern we are looking for. */
  if(objectMapOSC == null || !objectMapOSC.containsKey(m.addrPattern())){
    return;
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
      Button thisOSCObject = (Button) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(firstValue, false);
    } else if (typeMapOSC.get(m.addrPattern())=="temposweep") {
      Temposweep thisOSCObject = (Temposweep) objectMapOSC.get(m.addrPattern());
      thisOSCObject.setValue(int(firstValue));
    }
  } else if(m.checkTypetag("i")) {
    int firstValue =0;
    /* parse m and extract the values from the osc message arguments. */
    //  println(m);
    //m.print();
    firstValue = m.get(0).intValue();  
    // print("### received an osc message /test with typetag ifs.");


    if(typeMapOSC.get(m.addrPattern())=="button") {
      Button thisOSCObject = (Button) objectMapOSC.get(m.addrPattern());
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

void mouseClicked() {
  // turn a button on and off on mouse clicks
  // useful for developing without the max iphone craziness running
  Button b = selectedPanel.selectedTab.getButtonFromMouseCoords(mouseX, mouseY);
  if (b != null) {
    b.toggle();
  }
}















