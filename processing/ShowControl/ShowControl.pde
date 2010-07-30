import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import guicomponents.*;
import oscP5.*;
import netP5.*;

DMX DMXManager;
OSCManager OSCConnection;

SequencerState sequencerState;

EventDispatcher events;

LightingProgram program;

FadeBehavior testBehavior;
HueRotateBehavior testBehavior2;

ArrayList<Fixture> fixtures;
int huetemp=0;
color colortemp, colortemp2; 
Fixture test, test2, test3, test4, test5;


private GButton btnStart;
GWindow[] ctrlrWindow;

void setup(){

  /* example code*/
  colorMode(RGB);
  background(0);
  frameRate(200);

  //Set up OSC connection
  OSCConnection = new OSCManager("localhost");

  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  //create new DMX manager object with a refresh rate of 200Hz (Prcessing doesn't seem to be able to generate this refresh rate consistently)
  DMXManager = new DMX(this, 200);

  events = new EventDispatcher();

  //add three controllers to manager
  DMXManager.addController("COM5",108);
  DMXManager.addController("COM4",108);
  DMXManager.addController("COM3",108);

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
  test3 = fixtures.get(0);

  //add RGB channels, allowing DMX manager to assign addresses 
  test.addChannel("red");
  test.addChannel("green");
  test.addChannel("blue");
  //add RGB channels with fixed address assignments 
  test2.addChannel("red", 32);
  test2.addChannel("green", 33);
  test2.addChannel("blue", 34);

  test4.addChannel("red",64);
  test4.addChannel("green",65);
  test4.addChannel("blue",66);

  //set values for green and blue fixture channels directly
  test3.setChannel("green",200);
  test3.setChannel("blue",255);

  if(test3.traits.containsKey("RGBColorMixingTrait")){
    ((RGBColorMixingTrait)test3.trait("RGBColorMixingTrait")).setColorRGB(color(255)); 
  }


  test.addTrait("RGBColorMixing", new RGBColorMixingTrait(test));
  test2.addTrait("RGBColorMixing", new RGBColorMixingTrait(test2));
  test4.addTrait("RGBColorMixing", new RGBColorMixingTrait(test4));


  // Create test group
  FixtureGroup testGroup = new FixtureGroup("cube");
  testGroup.addTrait("RGBColorMixing", new RGBColorMixingTrait(testGroup));
  try{
    testGroup.addFixture(test);
    testGroup.addFixture(test2);
  } catch (FixtureTypeMismatchException ftme){}


  // create DMX Monitor button
  btnStart = new GButton(this, "DMX Monitor", 10,35,80,30);
  btnStart.setColorScheme(new GCScheme().GREEN_SCHEME);

  //test out the fade action
  ((RGBColorMixingTrait)test2.trait("RGBColorMixing")).setColorRGB(color(128,64,256));  //set start color   
  ((RGBColorMixingTrait)test.trait("RGBColorMixing")).setColorRGB(color(0,255,0));  //set start color   
  
  //test Behaviors
  //testBehavior = new FadeBehavior(test2, now()+10000, 5000, color(255));  // wait 10 secs, then fade to black over 5 secs
  testBehavior2 = new HueRotateBehavior(testGroup, now()+500); // wait .5 secs, then begin color cycling
  
  //initialize lighting program
  //need to add code here to initialize an array of lighting programs
  program = new LightingProgram();
  program.setupLighting();  
}


void draw(){
  colorMode(HSB);
  
  //step lighting program
  program.drawFrame();
  
  //the rest of this method is test code
  //print(events.eventQueue);
  
  //testBehavior.masterDrawFrame();
  testBehavior2.masterDrawFrame();
  events.flushExpired();

  background(((RGBColorMixingTrait)test.trait("RGBColorMixing")).getColorRGB()); 
}
