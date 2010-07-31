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

ArrayList<Fixture> fixtures = new ArrayList();
ArrayList<FixtureGroup> fixtureGroups = new ArrayList();

Fixture test, test2, test3, test4, test5;


private GButton btnStart;
GWindow[] ctrlrWindow;

void setup() {

  /* example code*/
  colorMode(RGB);
  background(0);
  frameRate(100);

  //Set up OSC connection
  OSCConnection = new OSCManager("localhost");

  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  //set up event queue
  events = new EventDispatcher();

  //create new DMX manager object with a refresh rate of 200Hz
  DMXManager = new DMX(this, 200);

  //add three controllers to manager
  DMXManager.addController("COM5",108);
  DMXManager.addController("COM4",108);
  DMXManager.addController("COM3",108);

  //create fixtures via fixture factory
  try {
    setupFixtures();
  } 
  catch (DataFormatException e) {
    print("An error occurred while parsing fixtures: " + e.getMessage() + "\n");
    exit();
  }
  
  test = fixtures.get(0);
  test2 = fixtures.get(1);
  test3 = fixtures.get(2);
  
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

  
  //initialize lighting program
  //need to add code here to initialize an array of lighting programs
  program = new LightingProgram();
  program.initialize();  
}


void draw(){
  colorMode(HSB);
  
  //step lighting program
  program.drawFrame();
  
  //the rest of this method is test code
  //print(events.eventQueue);
  
  // render fixture behaviors.  do fixture groups first, then fixtures
  for (FixtureGroup group : fixtureGroups) {
    Iterator behaviorIter = group.getBehaviorList().iterator();
    while (behaviorIter.hasNext()) {
      Behavior b = (Behavior)behaviorIter.next();
      b.masterDrawFrame();
    }
  }
  
  // now individual fixtures
  for (Fixture fixture : fixtures) {
    Iterator behaviorIter = fixture.getBehaviorList().iterator();
    while (behaviorIter.hasNext()) {
      Behavior b = (Behavior)behaviorIter.next();
      b.masterDrawFrame();
    }
  }
  
  events.flushExpired();

  background(((RGBColorMixingTrait)test.trait("RGBColorMixing")).getColorRGB()); 
}
