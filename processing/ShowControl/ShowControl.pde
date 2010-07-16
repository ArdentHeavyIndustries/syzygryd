import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import guicomponents.*;
import oscP5.*;
import netP5.*;

DMX DMXManager;
OSCManager OSCConnection;

SequencerState sequencerState;

ArrayList fixtures;
int huetemp=0;
color colortemp, colortemp2; 
Fixture test, test2, test3, test4, test5;

Queue readyQueue;
List waitingActions;
Iterator iterator;

//this is placeholder for however we decide to track time internally
//it should stay synced up with the sequencer in some meaninful way
int currentBeat = 0;

void setup(){

  /* example code*/
  colorMode(RGB);
  background(0);
  frameRate(30);

  //Set up OSC connection
  OSCConnection = new OSCManager("localhost");

  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  //create new DMX manager object with a refresh rate of 40Hz
  DMXManager = new DMX(this, 40);

  //add three controllers to manager
  DMXManager.addController("COM5");
  DMXManager.addController("COM4",256);
  DMXManager.addController("COM3",311);

  readyQueue = new LinkedList();
  waitingActions = new ArrayList();

  //todo here: sync currentBeat up with something meaningful from the sequencer.
  currentBeat = 0;

  //manually create three test fixtures on controller 0
  test = new Fixture(DMXManager, 0, "cube");
  test2 = new Fixture(DMXManager, 2, "cube");
  test4 = new Fixture(DMXManager, 0, "cube");
  test5 = new Fixture(DMXManager, 0, "cube");

  //create fixtures via fixture factory
  try {
    setupFixtures();
  } 
  catch (DataFormatException e) {
    print("An error occurred while parsing fixtures: " + e.getMessage() + "\n");
    exit();
  }
  test3 = (Fixture)fixtures.get(0);

  //add RGB channels, allowing DMX manager to assign addresses 
  test.addChannel("red");
  test.addChannel("green");
  test.addChannel("blue");
  //add RGB channels with fixed address assignments 
  test2.addChannel("red", 32);
  test2.addChannel("green", 33);
  test2.addChannel("blue", 34);

  test4.addChannel("red", 200);
  test4.addChannel("green", 201);
  test4.addChannel("blue", 202);

  test5.addChannel("red", 220);
  test5.addChannel("green", 221);
  test5.addChannel("blue", 222);

  //set values for green and blue fixture channels directly
  test2.setChannel("green",200);
  test2.setChannel("blue",255);

  test.addTrait("RGBColorMixing", new RGBColorMixingTrait(test));
  test2.addTrait("RGBColorMixing", new RGBColorMixingTrait(test2));
  test4.addTrait("RGBColorMixing", new RGBColorMixingTrait(test4));
  test5.addTrait("RGBColorMixing", new RGBColorMixingTrait(test5));

  // create controller displays
  displayControllers();

  //test out the fade action
  Fade newFade = new Fade(200, (RGBColorMixingTrait)test5.trait("RGBColorMixing"), 250, 1);
  waitingActions.add(newFade);
}


/* example of a simple hue rotation on a single fixture */

void draw(){
  colorMode(HSB);

  //ask all waiting actions "is it time yet?"
  //if they're ready, enqueue them for the next tick from the sequencer
  iterator = waitingActions.iterator();
  Action a;
  while(iterator.hasNext()) {
    a = (Action)iterator.next();
    if( a.isReady() ) {
      iterator.remove();
      readyQueue.add(a);
    }
  }

  //the rest of this method is test code

  colortemp = color(huetemp,255,255); 
  colortemp2  = color((huetemp+128)%256,255,255);
  ((RGBColorMixingTrait)test.trait("RGBColorMixing")).setColorRGB(colortemp); 
  ((RGBColorMixingTrait)test2.trait("RGBColorMixing")).setColorRGB(colortemp2); 
  //((RGBColorMixingTrait)test3.trait("RGBColorMixing")).setColorRGB(colortemp2); 
  huetemp++;
  huetemp %= 256;

  //test the blink action
  Blink newBlink = new Blink(currentBeat + 20, (RGBColorMixingTrait)test4.trait("RGBColorMixing"), colortemp);
  if(huetemp % 64 == 0) {
    waitingActions.add(newBlink);
  }

  tick(); //in reality this should only fire when we get sync info from the sequencer.  Or something.

}


void tick() {
  Action a;
  while(!readyQueue.isEmpty()) {
    a = (Action)readyQueue.remove();
    a.perform();
  }

  //todo here: sync up currentBeat with something meaningful in the sequencer
  currentBeat++;

}


