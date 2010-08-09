import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import processing.net.*;
import guicomponents.*;
import oscP5.*;
import netP5.*;

boolean SYZYVYZ = false;

Client syzygrydvyz;

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

int lastSyncTimeInMs;
int lastDrawTimeInMs;

private GButton btnStart;
GWindow[] ctrlrWindow;

void setup() {
  
  lastSyncTimeInMs = 0;
  lastDrawTimeInMs = millis();
  
  /* example code*/
  colorMode(RGB);
  background(0);
  frameRate(400);


  if (SYZYVYZ) {
    //Set up visualizer
    syzygrydvyz = new Client(this, "127.0.0.1", 3333);
  }

  //Set up OSC connection
  OSCConnection = new OSCManager("127.0.0.1");

  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  //set up event queue
  events = new EventDispatcher();

  //create new DMX manager object with a refresh rate of 200Hz
  DMXManager = new DMX(this);

  //add three controllers to manager
  DMXManager.addController("COM5",108);
  //DMXManager.addController("COM4",108);
  //DMXManager.addController("COM3",108);

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
  


  // create DMX Monitor button
  btnStart = new GButton(this, "DMX Monitor", 10,35,80,30);
  btnStart.setColorScheme(new GCScheme().GREEN_SCHEME);

  
  //initialize lighting program
  //need to add code here to initialize an array of lighting programs
  program = new LightingProgram();
  program.initialize();  
}


void draw(){
  
  updateStepPosition();
  
 
  //step lighting program
  program.drawFrame();
  
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
  
 
 // Enable following to debug contents of note array
 ///* 
 if(events.fired("step")){
    for (int y = 0; y < 10; y++){
      for (int p = 0; p < 3; p++){
        for (int x = 0; x < 16; x++){
          int t = sequencerState.curTab[p];
          print(sequencerState.notes[p][t][x][y]?"X":"_");
        }
        print("   ");
      }
      print("\n");
    }
    print("\n\n\n");
  }
  //*/
  
  //remove expired events
  events.flushExpired();

  background(((RGBColorMixingTrait)test.trait("RGBColorMixing")).getColorRGB());
  
  // send final state of lights to DMX controller(s)
  DMXManager.update();
}

void updateStepPosition(){
  if (lastSyncTimeInMs > 0) {
    int now = millis();
    //print("Time: " + now + "\n");
    int timeSinceLastDrawInMs = now - lastDrawTimeInMs;
    lastDrawTimeInMs = now;
  
    sequencerState.stepPosition = (sequencerState.stepPosition + getTimeInSteps(timeSinceLastDrawInMs)) % 16;
    //print("New position: " + sequencerState.stepPosition + "\n");
    
    int oldStep = sequencerState.curStep;
    sequencerState.curStep = (int)floor(sequencerState.stepPosition);
    if (oldStep != sequencerState.curStep) {
      events.fire("step");
    }
  }
}


float getTimeInSteps(int time) {
  float stepsPerBeat = 4;
  float msPerBeat = 60000 / (float)sequencerState.bpm;
  float msPerStep = msPerBeat / stepsPerBeat;

  float numSteps = time / msPerStep;
  //print ("Adding  " + numSteps + " steps to position.\n");
  return numSteps;
}
