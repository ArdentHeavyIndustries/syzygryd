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
Button[] buttons;
Temposweep temposweep;
HashMap typeMapOSC = new HashMap();
HashMap buttonsByRow = new HashMap();

/* A place to store active particle systems */
//ArrayList particleSystemsSimple;

/* Sets an initial Hue for colors to cycle from. Changes almost immediately */
int masterHue = 1;

class Panel {
  int id;
  int width, height;
  int buttonSize, buttonSpacing;
  int buttonCount;
  Button[] buttons;

  Panel(int _id, int _width, int _height, int _buttonSize, int _buttonSpacing) {
    id = _id;
    width = _width;
    height = _height;
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    buttonCount = 0;
    buttons = new Button[width * height];
  }

  /**
   * addButton adds a button to this panel
   */
  void addButton(Button b) {
    buttons[buttonCount] = b;
    buttonCount++;
  }

  /**
   * getButtonFromMouseCoords returns the button located at the
   * specified mouse coordinates.
   *
   * @return null if no button exists at the specified coordinates.
   */
  Button getButtonFromMouseCoords(int x, int y) {
    int row = getRow(y, buttonSpacing);
    int col = getCol(x, buttonSpacing);
    /*
    println("mouseX: " + x + ", mouseY: " + y);
    println("row: " + row + ", col: " + col);
    */

    return getButtonFromPanelCoords(row, col);
  }

  /**
   * getButtonFromPanelCoords returns the button at the specified
   * row and column in this panel.
   *
   * @return null if row or col are out of range.
   */
  Button getButtonFromPanelCoords(int row, int col) {
    if (row < 0 || col < 0 || row >= height || col >= width) {
      return null;
    }

    // println("Returning index: " + ((row * width) + col));
    // This is what we want if we create buttons one row at a time:
    // return buttons[(row * width) + col];
    // This is what we want if we create buttons one col at a time:
    // (this is the way things are currently implemented)
    return buttons[(col * height) + row];
  }
}

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
  oscP5 = new OscP5(this,9000);


  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. Currently not used at all. 
   * Probably should route to Max rather than direct to controller.
   */
  myRemoteLocation = new NetAddress("localhost",8000);

  // Connect to the server
  OscMessage connect = new OscMessage("/server/connect");
  oscP5.send(connect, myRemoteLocation);

  panels = new Panel[3];

  /* Set the total number of button objects here. 
   * total per layer by number of layers */
  buttons = new Button[160*3];

  int buttonCounter = 0;
  int buttonSize = height/11; // size of button based on real estate
  int buttonSpacing = buttonSize+4; // spacing btwn buttons based on buttonSize

  int panelWidth = 16;
  int panelHeight = 10;

  for (int i = 0; i < panels.length; i++) {
    panels[i] = new Panel(i, panelWidth, panelHeight, buttonSize, buttonSpacing);
  }

  /* sets up array and defines which osc messages apply to which panel */
  for(int i = 1; i <= panelWidth; i++){ // set
    Button[] thisRowButtons;
    thisRowButtons = new Button[panelHeight + 1];
    for(int j = 1; j <= panelHeight; j++){
      Button thisButton;

      /*
        I believe the button creation code can be shortened to the for
        loop below, except for the line:
        thisRowButtons[j] = thisButton;
        which exists only in the panel 2 block.  The intent of
        thisRowButtons is unclear to me.

      for (int k = 0; k < panels.length; k++) {
        thisButton = new Button(
          //     particleSystemsSimple,
          buttonSpacing*i, // button X
          (buttonSpacing*j)-((buttonSize)), //button Y
          buttonSize, // button length
          panels[k] //button panel #
        ); 

        // put current button into hashmap of all buttons from osc
        objectMapOSC.put (
          "/" + (k + 1) + "/multitoggle1/" + (11 - j) + "/" + i, thisButton);
        typeMapOSC.put (
          "/" + (k + 1) + "/multitoggle1/" + (11 - j) + "/" + i, "button");
        // put current button into array of stored buttons
        buttons[buttonCounter] = thisButton;
        panels[k].addButton(thisButton);
        buttonCounter++;
      }
      */

      /* panel 1 */
      thisButton = new Button(
 //       particleSystemsSimple,
        buttonSpacing*i, // button X
        (buttonSpacing*j)-((buttonSize)), //button Y
        buttonSize, // button length
        buttonSpacing,
        panels[0] //button panel
      ); 
      objectMapOSC.put ("/1/multitoggle1/"+(11-j)+"/"+i,   thisButton); //put current button into hashmap of all buttons from osc
      typeMapOSC.put ("/1/multitoggle1/"+(11-j)+"/"+i, "button");
      buttons[buttonCounter] = thisButton; // put current button into array of stored buttons
      panels[0].addButton(thisButton);
      buttonCounter++;

      /* panel 2 */
      thisButton = new Button(
   //     particleSystemsSimple,
        buttonSpacing*i,
        (buttonSpacing*j)-((buttonSize)),
        buttonSize,
        buttonSpacing,
        panels[1]
      );
      objectMapOSC.put ("/2/multitoggle1/"+(11-j)+"/"+i, thisButton); //put current button into hashmap of all buttons from osc
      typeMapOSC.put ("/2/multitoggle1/"+(11-j)+"/"+i, "button");
      thisRowButtons[j] = thisButton;
      buttons[buttonCounter] = thisButton; // put current button into array of stored buttons
      panels[1].addButton(thisButton);
      buttonCounter++;

      /* panel 3 */
      thisButton = new Button(
   //     particleSystemsSimple,
        buttonSpacing*i,
        buttonSpacing*j-((buttonSize)),
        buttonSize,
        buttonSpacing,
        panels[2]
      );
      objectMapOSC.put ("/3/multitoggle1/"+(11-j)+"/"+i, thisButton); //put current button into hashmap of all buttons from osc
      typeMapOSC.put ("/3/multitoggle1/"+(11-j)+"/"+i, "button");
      buttons[buttonCounter] = thisButton; // put current button into array of stored buttons
      panels[2].addButton(thisButton);
      buttonCounter++;
    }
    buttonsByRow.put(i, thisRowButtons);
  }

  temposweep = new Temposweep(buttonSize, buttonSpacing, buttonsByRow);
  objectMapOSC.put ("/temposlider/step", temposweep);
  typeMapOSC.put ("/temposlider/step", "temposweep");
}


int curSecond = 0;

void draw() {

  background (0);
  for(int i = 0; i < buttons.length; i++){
    buttons[i].draw(false);
    buttons[i].setHue(masterHue);
  }


  if(second() % 5 == 0 && second() != curSecond){ //does changing the modulo here make color cycle faster or slower?
    masterHue+=1;
    if(masterHue > 100){
      masterHue -=100; 
    }
    curSecond = second();
  }
  
  temposweep.draw();
  
  // Cycle through all particle systems, run them and delete old ones
/*  for (int i = particleSystemsSimple.size()-1; i >= 0; i--) {
    ParticleSystemSimple psys = (ParticleSystemSimple) particleSystemsSimple.get(i);
    psys.run();
    if (psys.dead()) {
      particleSystemsSimple.remove(i);
    }
  }
*/
  for(int i = 0; i < buttons.length; i++){
    buttons[i].draw(true);
  }

}



void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */

  if(! objectMapOSC.containsKey(theOscMessage.addrPattern())){
    return;
  }


  /* check if the typetag is the right one. */
  if(theOscMessage.checkTypetag("f")) {
    float firstValue =0;
    /* parse theOscMessage and extract the values from the osc message arguments. */
    //  println(theOscMessage);
    //theOscMessage.print();
    firstValue = theOscMessage.get(0).floatValue();  
    // print("### received an osc message /test with typetag ifs.");


    if(typeMapOSC.get(theOscMessage.addrPattern())=="button") {
      Button thisOSCObject = (Button) objectMapOSC.get(theOscMessage.addrPattern());
      thisOSCObject.setValue(int(firstValue));
    } 
    else if (typeMapOSC.get(theOscMessage.addrPattern())=="temposweep") {
      Temposweep thisOSCObject = (Temposweep) objectMapOSC.get(theOscMessage.addrPattern());
      thisOSCObject.setValue(int(firstValue));
    }
  } 
  else if(theOscMessage.checkTypetag("i")) {
    int firstValue =0;
    /* parse theOscMessage and extract the values from the osc message arguments. */
    //  println(theOscMessage);
    //theOscMessage.print();
    firstValue = theOscMessage.get(0).intValue();  
    // print("### received an osc message /test with typetag ifs.");


    if(typeMapOSC.get(theOscMessage.addrPattern())=="button") {
      Button thisOSCObject = (Button) objectMapOSC.get(theOscMessage.addrPattern());
      thisOSCObject.setValue(firstValue);
    } 
    else if (typeMapOSC.get(theOscMessage.addrPattern())=="temposweep") {
      Temposweep thisOSCObject = (Temposweep) objectMapOSC.get(theOscMessage.addrPattern());
      thisOSCObject.setValue(firstValue);
    }
  }
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());




}

void mouseClicked() {
  // turn a button on and off on mouse clicks
  // useful for developing without the max iphone craziness running
  Button b = panels[1].getButtonFromMouseCoords(mouseX, mouseY);
  if (b != null) {
    if(b.getValue()) {
      b.setValue(0);
    } else {
      b.setValue(1);
    }
  }
}















