// ------------------------------------------------- LightingTest  --------------------------------------
// Steps through every single DMX channel on the given arm. Does not use sync.
  
int TEST_STEP_TIME_MS;

// http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Lighting_Control#DMX_Addresses
// Each DMX universe (of which there are three, for three arms) is addressed as follows:
//     * 1-108 are cubes 1-36 R,G,B interleaved (108)
//     * 109-117 are control cubes (9)
//     * 118-141 are flame effects 1-8 on arms A, B, C (24)
//     * 142-144 are hi-pressure valves on arms A,B,C (3)
//     * 145 is the central poofer (1)
//     * 146 is the tornado fan (1)
//     * 147 is the tornado fuel (wired so that it cannot open the valve if the fan is not running) (1) 
// XXX i'm assuming that the wiki docs start counting at 1 and the code starts counting at 0, but could someone else confirm that?
int TEST_FIRST_CHANNEL;
int TEST_LAST_CHANNEL;

// in the range [0,255]
// fire control board closes relays only when it sees the special DMX value set by FireControl.FIRE_DMX_MAGIC (85)
int TEST_VAL;

boolean TEST_MULTIPLE_ARMS;
boolean TEST_HIGH_PRESSURE_VALVES;

// These are the default values, if not set in the file.
// Use String's here, regardless of the final type.
// These should be consistent with the commented out lines in the
// example etc/showcontrol.properties file.
final String DEFAULT_TEST_STEP_TIME_MS         = "250";
final String DEFAULT_TEST_FIRST_CHANNEL        = "0";
final String DEFAULT_TEST_LAST_CHANNEL         = "107";
final String DEFAULT_TEST_VAL                  = "255";
final String DEFAULT_TEST_MULTIPLE_ARMS        = "true";
final String DEFAULT_TEST_HIGH_PRESSURE_VALVES = "false";

void sendDMX2(int addr, int val)
{
  sendDMX(addr, val);
  if (TEST_MULTIPLE_ARMS) {
    sendDMX(addr+8, val);
    sendDMX(addr+16, val);
  }  
}

class LightingTest extends LightingProgram {
 
  float lastTime;
  int lastChannel;
 
  LightingTest() {
    info("Lighting Test enabled");
    setupProps();

    lastTime = now();
    lastChannel = TEST_FIRST_CHANNEL;
    sendDMX2(TEST_FIRST_CHANNEL,TEST_VAL);
   
    // Open the high pressure valves on each arm
    if (TEST_HIGH_PRESSURE_VALVES) {
      info("Opening the high pressure valves on each arm");
      fireDMX(141, true);
      fireDMX(142, true);
      fireDMX(143, true);
    }
  }

  // keep the test props (other than TEST_MODE itself) here, rather than in ShowControl
  void setupProps() {
    defaultProps.setProperty("testStepTimeMs", DEFAULT_TEST_STEP_TIME_MS);
    defaultProps.setProperty("testFirstChannel", DEFAULT_TEST_FIRST_CHANNEL);
    defaultProps.setProperty("testLastChannel", DEFAULT_TEST_LAST_CHANNEL);
    defaultProps.setProperty("testVal", DEFAULT_TEST_VAL);
    defaultProps.setProperty("testMultipleArms", DEFAULT_TEST_MULTIPLE_ARMS);
    defaultProps.setProperty("testHighPressureValves", DEFAULT_TEST_HIGH_PRESSURE_VALVES);

    TEST_STEP_TIME_MS = getIntProperty("testStepTimeMs");
    TEST_FIRST_CHANNEL = getIntProperty("testFirstChannel");
    TEST_LAST_CHANNEL = getIntProperty("testLastChannel");
    TEST_VAL = getIntProperty("testVal");
    TEST_MULTIPLE_ARMS = getBooleanProperty("testMultipleArms");
    TEST_HIGH_PRESSURE_VALVES = getBooleanProperty("testHighPressureValves");

    info("TEST_STEP_TIME_MS = " + TEST_STEP_TIME_MS);
    info("TEST_FIRST_CHANNEL = " + TEST_FIRST_CHANNEL);
    info("TEST_LAST_CHANNEL = " + TEST_LAST_CHANNEL);
    info("TEST_VAL = " + TEST_VAL);
    info("TEST_MULTIPLE_ARMS = " + TEST_MULTIPLE_ARMS);
    info("TEST_HIGH_PRESSURE_VALVES = " + TEST_HIGH_PRESSURE_VALVES);
  }
    
  // ignore steps in case we are not getting sync; use internal timer
  void advance(float steps) {
 
     int curTime = now();
 
     if (curTime > lastTime + TEST_STEP_TIME_MS) {
       sendDMX2(lastChannel, 0);
       lastChannel++;
       if (lastChannel > TEST_LAST_CHANNEL)
         lastChannel = TEST_FIRST_CHANNEL;
       sendDMX2(lastChannel, TEST_VAL);      
       info("channel " + lastChannel + " on.");
       lastTime = curTime;
     }
   }
 
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
