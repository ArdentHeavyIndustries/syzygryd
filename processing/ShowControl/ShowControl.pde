import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import processing.net.*;
import guicomponents.*;
import oscP5.*;
import netP5.*;

import java.io.FileReader;
import java.io.IOException;
import java.lang.NumberFormatException;
import java.util.Properties;

// ------------------------- Program Configuration ------------------------- 

// The actual setting of Properties is below in setupProps() (called
// from setup()), b/c Processing fails to compile if it is located
// here.
// But the variables are defined here so that we can reference them
// globally.
Properties defaultProps;
Properties props;

// Not *all* configuration values are exposed to runtime editing.
// Only those that are likely to change during testing or between test and production.

final int CUBES_PER_ARM = 36;
final int EFFECTS_PER_ARM = 8;

final int PANELS = 3;    // Should probably just use PANELS and PITCHES constants from SequencerState, but we can
final int PITCHES = 10;  // wait until 2.0 to make any changes.

final int FRAMERATE = 100;
final int OSC_UPDATE_INTERVAL_MS = 500;

// These are the default values, if not set in the file.
// Use String's here, regardless of the final type.
// These should be consistent with the commented out lines in the
// example etc/controller.properties file.
final String DEFAULT_SEND_DMX                = "true";
final String DEFAULT_TEST_MODE               = "false"; // in test mode we output DMX on sequential channels -- see LightingTest
final String DEFAULT_SYZYVYZ                 = "false";
final String DEFAULT_ASCII_SEQUENCER_DISPLAY = "false";

// These will be set in setupProps()

boolean SEND_DMX; 
boolean TEST_MODE;                
boolean SYZYVYZ;
boolean ASCII_SEQUENCER_DISPLAY;

// ----------------- Variable Declaration & Initialization -----------------

// DMX Control
DMX DMXManager;
int numControllers = 0;

// Visualizer Connection
Client syzygrydvyz;

// Sequencer State and Events
OSCManager OSCConnection;
OSCManager OSCConnection_touchOSC;
SequencerState sequencerState;
EventDispatcher events;

// Time Tracking
int lastSyncTimeInMs;
int lastDrawTimeInMs;
int lastOscUpdateTimeInMs;

// Fixtures and Groups
ArrayList<Fixture> fixtures = new ArrayList();
ArrayList<FixtureGroup> fixtureGroups = new ArrayList();
FixtureGroup[] arm = new FixtureGroup[6];
Fixture[] groundCube = new Fixture[3];

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

// Panel UI colors
color panelColor[];

void setup() {
  setupProps();

  colorMode(HSB, 360.0, 100.0, 100.0);
  background(0);
  frameRate(FRAMERATE);
  
  lastSyncTimeInMs = 0;
  lastDrawTimeInMs = millis();
  lastOscUpdateTimeInMs = 0;
   
  //Set up OSC connection
  OSCConnection = new OSCManager("255.255.255.255",9002,9002);  // receive from sequencer, send to controller
  OSCConnection_touchOSC = new OSCManager("255.255.255.255",8005,9005);

  //Instantiate sequencer state storage
  sequencerState = new SequencerState();

  // Set initial remote panel colors
  panelColor = new color[sequencerState.PANELS]; // set color array length to the number of panels
  for (int i = 0; i < sequencerState.PANELS; i++){
    panelColor[i] = color((float)((360 * i) / sequencerState.PANELS), 100.0, 100.0); // divide color wheel equally between number of panels
  }

  //set up event queue
  events = new EventDispatcher();

  //create new DMX manager object
  DMXManager = new DMX(this);

  // Uncomment the following line to enumerate available serial devices on the console: the Enttecs should 
  // all appear as "cu.usbserial-XXXXXXXX", where XXXXXXXX is some unique identifier. Copy the results into 
  // the DMXmanager.addController() statements below.
  
  //Serial.list();

  //add three controllers to manager
  DMXManager.addController("/dev/cu.usbserial-EN077331",149);
  DMXManager.addController("/dev/cu.usbserial-EN077490",149);
  DMXManager.addController("/dev/cu.usbserial-EN075581",149);
  
  // start fire control
  fireControlInitialize();
  
  //Set up visualizer
  if (SYZYVYZ) {
    syzygrydvyz = new Client(this, syzyVyzIP, syzyVyzPort);
  }


  //create fixtures via fixture factory
  try {
    setupFixtures();
  } 
  catch (DataFormatException e) {
    warn("An error occurred while parsing fixtures: " + e.getMessage());
    exit();
  }

  //create cube arm groups
  for (int i = 0; i < 3; i++){
    arm[i] = new FixtureGroup("cube");
    arm[i].addTrait("RGBColorMixing", new RGBColorMixingTrait(arm[i]));
    for (int j = (i * 69) + 1; j < (i * 69) + 36 + 1; j++){  // 36 cubes per arm, skip first fixture on each arm (ground cubes)
      try{
        arm[i].addFixture(fixtures.get(j));
      } catch (FixtureTypeMismatchException ftme){}
    }
  }

  //create ground cube fixture array
  for (int i = 0; i < 3; i++) {
    groundCube[i] = fixtures.get(i*69);
  }
  

  //create fire arm groups
  int k = 39;
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

  // Instantiate programs. They add it automatically to the list of available lighting programs.
  if (TEST_MODE) {
    new LightingTest();
  }
  
  new FrameBrulee(); 
  new TestProgram();
  new TestProgram2();

  // To start with, first program on the list is active
  program = programList.get(activeProgram); // Get active program
  program.initialize();  // Initialize active program  

  // Run with the high pressure valves open
  fireDMXRaw(141, true); 
  fireDMXRaw(142, true); 
  fireDMXRaw(143, true); 
}


void draw(){
  
  // Move active program forward
  float elapsedSteps = updateStepPosition();
  program.advance(elapsedSteps);
  
  // Composite layers in order, accumulating to a LightingState
  renderedLightState.clear();
  program.render(renderedLightState);
  
  // Set dem lights!
  if (!TEST_MODE) {
    renderedLightState.output();
  }
  
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

  // advance fire control timers
  fireControlAdvance(elapsedSteps);

  // textmode sequencer display -- useful for debugging. enable in config file.
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
  
  // update remote panel UI color via OSC
  int now = millis();
  if (now - lastOscUpdateTimeInMs >= OSC_UPDATE_INTERVAL_MS) {	// only send if update interval has elapsed
    //debug ("Sending UI color");
    lastOscUpdateTimeInMs = now;
//    OSCConnection.sendUIColor();
  }
  
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

int totalSteps = -1;

// Returns steps elapsed since last call
float updateStepPosition(){
  float elapsed = 0;
  
  if (lastSyncTimeInMs > 0) {
    int now = millis();
    //debug("Time: " + now);
    int timeSinceLastDrawInMs = now - lastDrawTimeInMs;
    int timeSinceLastSyncInMs = now - lastSyncTimeInMs;
    lastDrawTimeInMs = now;

    elapsed = getTimeInSteps(timeSinceLastDrawInMs);
    
    sequencerState.stepPosition = (sequencerState.stepPosition + getTimeInSteps(timeSinceLastDrawInMs)) % 16;
    //debug("New position: " + sequencerState.stepPosition);
    
    // See if we've entered a new step; if so, fire the "step" event.
    int oldStep = sequencerState.curStep;
    sequencerState.curStep = (int)floor(sequencerState.stepPosition);
    
    if (oldStep != sequencerState.curStep) {
      events.fire("step");
      //debug("Step!");
      
      if (totalSteps != -1)
        totalSteps++;
        
      // fire events on the bar and 4 bar marks
      if (sequencerState.curStep == 0) {
        events.fire("bar");
  
        // start counting total steps on a bar boundary, so totalSteps % 16 = 0 when we start a new bar
        if (totalSteps == -1)
          totalSteps = 0;

        if (totalSteps % 16 == 0)
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
  //debug ("Adding  " + numSteps + " steps to position.");
  return numSteps;
}

float curTimeInSteps() {
  return getTimeInSteps(now());
}

// super-simple DMX interface
void sendDMX(int universe, int channel, int value) {
   DMXManager.setChannel(universe, channel, (byte)value); 
}

// two arg version: send to universe zero. Good for fire control.
void sendDMX(int channel, int value) {
   DMXManager.setChannel(0, channel, (byte)value); 
}

///////////////////////////////////////////////////////////////////////////////
// property related methods

// XXX properties are almost completely copied from controller_display/controller_display.pde
// in the long term we should share code

void setupProps() {
  // Processing fails to compile the sketch if this mucking with
  // Properties is done in the global declarations section above, so
  // keep it here (invoked from setup()).

  // Read configuration from a properties file
  // linux or mac
  final String PROPS_FILE = "/opt/syzygryd/etc/showcontrol.properties";
  // windows
  //final String PROPS_FILE = "C:\syzygryd\etc\showcontrol.properties";
  
  // Configure default values, if not set in the file
  defaultProps = new Properties();
  defaultProps.setProperty("sendDmx", DEFAULT_SEND_DMX);
  defaultProps.setProperty("testMode", DEFAULT_TEST_MODE);
  defaultProps.setProperty("syzyvyz", DEFAULT_SYZYVYZ);
  defaultProps.setProperty("asciiSequencerDisplay", DEFAULT_ASCII_SEQUENCER_DISPLAY);
  
  props = new Properties(defaultProps);
  info("Loading properties from " + PROPS_FILE);
  try {
    props.load(new FileReader(PROPS_FILE));
  } catch (IOException ioe) {
    warn ("Can't load properties file, will use all default values: " + PROPS_FILE);
  }

  SEND_DMX = getBooleanProperty("sendDmx");
  TEST_MODE = getBooleanProperty("testMode");
  SYZYVYZ = getBooleanProperty("syzyvyz");
  ASCII_SEQUENCER_DISPLAY = getBooleanProperty("asciiSequencerDisplay");

  info("SEND_DMX = " + SEND_DMX);
  info("TEST_MODE = " + TEST_MODE);
  info("SYZYVYZ = " + SYZYVYZ);
  info("ASCII_SEQUENCER_DISPLAY = " + ASCII_SEQUENCER_DISPLAY);
}

String getStringProperty(String key) {
  // we don't need to separately account for a default value,
  // since this was taken care of when setting up defaultProps and props in setup()
  return props.getProperty(key);
}

int getIntProperty(String key) {
  int value;
  try {
    value = Integer.parseInt(props.getProperty(key));
  } catch (NumberFormatException nfe) {
    try {
      value = Integer.parseInt(defaultProps.getProperty(key));
    } catch (NumberFormatException nfe2) {
      throw new NumberFormatException("Value for property " + key +
                                      " not an int (" + props.getProperty(key) +
                                      "), but neither is the default value either (" + defaultProps.getProperty(key) + ")");
    }
    warn ("Value for property " + key +
          " not an int (" + props.getProperty(key) +
          "), using default value: " + value);
  }
  return value;
}

boolean getBooleanProperty(String key) {
  boolean value;
  try {
    value = Boolean.parseBoolean(props.getProperty(key));
  } catch (NumberFormatException nfe) {
    try {
      value = Boolean.parseBoolean(defaultProps.getProperty(key));
    } catch (NumberFormatException nfe2) {
      throw new NumberFormatException("Value for property " + key +
                                      " not a boolean (" + props.getProperty(key) +
                                      "), but neither is the default value either (" + defaultProps.getProperty(key) + ")");
    }
    warn ("Value for property " + key +
          " not an boolean (" + props.getProperty(key) +
          "), using default value: " + value);
  }
  return value;
}

///////////////////////////////////////////////////////////////////////////////
// logging helper methods

// XXX logging is completely copied from controller_display/controller_display.pde
// in the long term we should share code

// pad a string to at least a minimum size by prepending the given char
// the StringBuffer is modified in place
void prefixPad(StringBuffer sb, int minsize, char c) {
  int toAdd = minsize - sb.length();
  if (toAdd > 0) {
    for (int i = 0; i < toAdd; i++) {
      sb.insert(0, c);
    }
  }
}

String getTime() {
  Calendar cal = Calendar.getInstance();

  StringBuffer year = new StringBuffer();
  year.append(cal.get(Calendar.YEAR));
  prefixPad(year, 4, '0');
  StringBuffer month = new StringBuffer();
  month.append(cal.get(Calendar.MONTH) + 1);
  prefixPad(month, 2, '0');
  StringBuffer day = new StringBuffer();
  day.append(cal.get(Calendar.DAY_OF_MONTH));
  prefixPad(day, 2, '0');
  StringBuffer hour = new StringBuffer();
  hour.append(cal.get(Calendar.HOUR_OF_DAY));
  prefixPad(hour, 2, '0');
  StringBuffer min = new StringBuffer();
  min.append(cal.get(Calendar.MINUTE));
  prefixPad(min, 2, '0');
  StringBuffer sec = new StringBuffer();
  sec.append(cal.get(Calendar.SECOND));
  prefixPad(sec, 2, '0');
  StringBuffer millis = new StringBuffer();
  millis.append(cal.get(Calendar.MILLISECOND));
  prefixPad(millis, 3, '0');

  StringBuffer date = new StringBuffer();
  date.append('[');
  date.append(year);
  date.append('/');
  date.append(month);
  date.append('/');
  date.append(day);
  date.append(' ');
  date.append(hour);
  date.append(':');
  date.append(min);
  date.append(':');
  date.append(sec);
  date.append('.');
  date.append(millis);
  date.append(']');

  return date.toString();
}

///////////////////////////////////////////////////////////////////////////////
// simple logging

// the idea here with this simple logging is that you should feel free to log infrequent but important events with info().  these are always in production.
// problem cases are logged with warn(), and are also always in production.
// log more verbose stuff with debug().  normally the contents of this method are commented out.  feel free to uncomment for debugging, but DO NOT CHECK THAT IN !!!
// but really verbose stuff is probably better to even comment out the call to debug() in the code, so as not to incur the overhead of the method call.
// (the processing preprocessor does *not* optimize that away)

// XXX logging is completely copied from controller_display/controller_display.pde
// in the long term we should share code

void debug(String msg) {
  // feel free to uncomment this for debugging, but DO NOT CHECK IT IN if you do so.
  //System.out.println(getTime() + " " + msg);
}

void info(String msg) {
  System.out.println(getTime() + " " + msg);
}

void warn(String msg) {
  System.err.println(getTime() + " WARNING: " + msg);
}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 2
**   tab-width: 2
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=2 tabstop=2 expandtab cindent shiftwidth=2
**
*/
