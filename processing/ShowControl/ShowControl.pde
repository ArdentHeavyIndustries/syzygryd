import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import processing.net.*;
import guicomponents.*;
import oscP5.*;
import netP5.*;

// ------------------------- Program Configuration ------------------------- 

int CUBES_PER_ARM = 36;
int EFFECTS_PER_ARM = 8;

int PANELS = 3;
int PITCHES = 10;

int FRAMERATE = 200;
boolean SEND_DMX = true; //IMPORTANT: set to 'true' for production

boolean SYZYVYZ = false;
boolean ASCII_SEQUENCER_DISPLAY = false;

// ----------------- Variable Declaration & Initialization -----------------

// DMX Control
DMX DMXManager;

// Sequencer State and Events
OSCManager OSCConnection;
OSCManager OSCConnection_touchOSC;
SequencerState sequencerState;
EventDispatcher events;

// Time Tracking
int lastSyncTimeInMs;
int lastDrawTimeInMs;

// Fixtures and Groups
ArrayList<Fixture> fixtures = new ArrayList();
ArrayList<FixtureGroup> fixtureGroups = new ArrayList();
FixtureGroup[] arm = new FixtureGroup[6];

// Lighting Programs
ArrayList<LightingProgram> programList = new ArrayList();
int activeProgram = 0;
LightingProgram program;

LightingState renderedLightState = new LightingState();

// User Interface
private GButton btnStart;
GWindow[] ctrlrWindow;

// Visualizer Connection
String syzyVyzIP = "127.0.0.1";
int syzyVyzPort = 3333;

void setup() {
  
  lastSyncTimeInMs = 0;
  lastDrawTimeInMs = millis();
  
  // example code
  colorMode(RGB);
  background(0);
  frameRate(FRAMERATE);

  //Set up OSC connection
  // OSCManager (host, receive, send)
  OSCConnection = new OSCManager("255.255.255.255",9002,9002);  // receive from sequencer, send to controller
  OSCConnection_touchOSC = new OSCManager("255.255.255.255",8005,9005);


  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  //set up event queue
  events = new EventDispatcher();

  //create new DMX manager object
  DMXManager = new DMX(this);

  //add three controllers to manager
  //DMXManager.addController("COM5");
  DMXManager.addController("/dev/cu.usbserial-EN075577");
  DMXManager.addController("/dev/cu.usbserial-00003004");
  DMXManager.addController("/dev/cu.usbserial-FTSK5W77");
  //DMXManager.addController("COM5",108);
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

  //create cube arm groups
  for (int i = 0; i < 3; i++){
    arm[i] = new FixtureGroup("cube");
    arm[i].addTrait("RGBColorMixing", new RGBColorMixingTrait(arm[i]));
    for (int j = i * 66; j < (i * 66)+36; j++){  // 36 cubes per arm
      try{
        arm[i].addFixture(fixtures.get(j));
      } catch (FixtureTypeMismatchException ftme){}
    }
  }

  //create fire arm groups
  int k = 36;
  for (int i = 3; i < 6; i++){
    arm[i] = new FixtureGroup("fire");
    arm[i].addTrait("Fire", new RGBColorMixingTrait(arm[i]));
    for (int j = 0; j < 8; j++){  
      try{
        arm[i].addFixture(fixtures.get(k++));
      } catch (FixtureTypeMismatchException ftme){}
    }
  }

  // create DMX Monitor button
  btnStart = new GButton(this, "DMX Monitor", 10,35,80,30);
  btnStart.setColorScheme(new GCScheme().GREY_SCHEME);

  new FrameBrulee(); // Instantiate a program. This adds it automatically to the list of available lighting programs.
  new TestProgram();
  new TestProgram2();

  program = programList.get(activeProgram); // Get active program
  program.initialize();  // Initialize active program  

}


void draw(){
  
  // Move active program forward
  float elapsedSteps = updateStepPosition();
  program.advance(elapsedSteps);
  
  // Composite layers in order, accumulating to a LightingState
  renderedLightState.clear();
  program.render(renderedLightState);
  
  // Set dem lights!
  renderedLightState.output();
  
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


 // textmode sequencer display -- useful for debugging. enable in config variables above.
 if(ASCII_SEQUENCER_DISPLAY){ 
   if(events.fired("step")){
      for (int y = 0; y < 10; y++){
        for (int p = 0; p < 3; p++){
          for (int x = 0; x < 16; x++){
            int t = sequencerState.curTab[p];
            print(sequencerState.notes[p][t][x][y]?"X":(x==sequencerState.curStep?"|":"_"));
          }
          print("   ");
        }
        print("\n");
      }
      print("\n\n\n");
    }
 }
  
  //remove expired events
  events.flushExpired();
  
  // send final state of lights to DMX controller(s)
  DMXManager.update();
}

void keyPressed(){
  if (key == CODED) {
    switch(keyCode) {
      case RIGHT:
        nextProgram();
        break;
      case LEFT:
        prevProgram();
        break;
    }
  }
}


// Returns steps elapsed since last call
float updateStepPosition(){
  float elapsed = 0;
  
  if (lastSyncTimeInMs > 0) {
    int now = millis();
    //print("Time: " + now + "\n");
    int timeSinceLastDrawInMs = now - lastDrawTimeInMs;
    int timeSinceLastSyncInMs = now - lastSyncTimeInMs;
    lastDrawTimeInMs = now;

    elapsed = getTimeInSteps(timeSinceLastDrawInMs);
    
    sequencerState.stepPosition = (sequencerState.stepPosition + getTimeInSteps(timeSinceLastDrawInMs)) % 16;
    //print("New position: " + sequencerState.stepPosition + "\n");
    
    // See if we've entered a new step; if so, fire the "step" event.
    int oldStep = sequencerState.curStep;
    sequencerState.curStep = (int)floor(sequencerState.stepPosition);
    if (oldStep != sequencerState.curStep) {
      events.fire("step");
      //print("Step!\n");
      
      // fire events on the bar and 4 bar marks
      if (sequencerState.curStep == 0) {
        events.fire("bar");
      }
      if ((sequencerState.ppqPosition % 16) == 0) {
        events.fire("4bars");
      }
      
      // See if we're playing any notes this step; if so, fire "notes" event.
      boolean[] notesToPlay = new boolean[3];
      for (int i = 0; i < sequencerState.PANELS; i++){
        for (int j = 0; j < sequencerState.PITCHES; j++){
          if (sequencerState.notes[i][sequencerState.curTab[i]][sequencerState.curStep][j]){
            notesToPlay[i] = true;
          }
        }
      }
      
      boolean anyNotesToPlay = false;
      for (int i=0; i<3; i++)
        if (notesToPlay[i]) {
          events.fire("notes" + Integer.toString(i));
          anyNotesToPlay = true;
        }
        
      if (anyNotesToPlay) {
        events.fire("notes");
      }
      
    }
  }
  
  return elapsed;
}


float getTimeInSteps(int time) {
  float stepsPerBeat = 4;
  float msPerBeat = 60000 / (float)sequencerState.bpm;
  float msPerStep = msPerBeat / stepsPerBeat;

  float numSteps = time / msPerStep;
  //print ("Adding  " + numSteps + " steps to position.\n");
  return numSteps;
}

float curTimeInSteps() {
  return getTimeInSteps(now());
}

