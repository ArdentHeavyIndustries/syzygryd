import java.util.HashSet;
import java.util.Set;

// FireControl
// Processes OSC messsages, runs manual fire control of main effect and tornado
// Patterned fire control is handled within FrameBrulee, because we already have all the framework there,
// and we need to layer the manually-triggered patterned fire effects with the fire visualizers

// Global state
boolean fcUIMasterFireArm = false;    // master fire arm switch. FrameBrulee looks at this too.

int fcMainOnTime;
boolean fcMainOn = false;
int fcFanOnTime;

// UI state mirrors
float fcUIMainDuration = 0.5;  // seconds
boolean fcUITornadoFan = false;
boolean fcUITornadoReady = false;
boolean fcUITornadoFuel = false;
int fcUIArm = 0;

// this is consulted if FLAME_EFFECTS_78_DISABLE is set.  initialized below in fireControlInitialize()
Set fireBlacklist = new HashSet();
// use a single persistent Integer so that we don't need to create a new Object for every check
Integer fireBlacklistInteger = new Integer(-1);

// Initialize mostly puts the touchOSC in a coherent state
// globals, above, need to start with poofer, ready, fan, tornado all off
//
// It also sets the fireBlacklist
void fireControlInitialize() { 
  info("Initializing fire control");
  sendTouchOSCMsg("/fireMasterArm/makeFire", fcUIMasterFireArm);
  sendTouchOSCMsg("/fireControl/main", false);
  sendTouchOSCMsg("/fireControl/mainDuration", fcUIMainDuration);
  sendTouchOSCMsg("/fireControl/mainDurationLabel", "duration " + roundTo2Places(fcUIMainDuration) + " seconds");  
  sendTouchOSCMsg("/fireControl/tornadoFan", fcUITornadoFan);
  sendTouchOSCMsg("/fireControl/tornadoReady", false);
  sendTouchOSCMsg("/fireControl/tornadoFuel", false);

  // These are the flame effect addresses for 7/8 effects
  // We disable all of these if FLAME_EFFECTS_78_DISABLE is set
  fireBlacklist.add(new Integer(123));
  fireBlacklist.add(new Integer(124));
  fireBlacklist.add(new Integer(131));
  fireBlacklist.add(new Integer(132));
  fireBlacklist.add(new Integer(139));
  fireBlacklist.add(new Integer(140));
  info("Fire blacklist contains: " + fireBlacklist);
}

// Constants
float FAN_WARMUP_TIME = 5000;  // ms after fan on before fuel can go on

int POOFER_DMX_ADDR = 146;
int TORNADO_FAN_DMX_ADDR = 144;
int TORNADO_FUEL_DMX_ADDR = 145;

int FIRE_DMX_MAGIC = 85;     // fire control board closes relays only when it sees this DMX value

int flameEffectDMXAddr(int arm, int effect) {
  return 117 + arm*8 + effect;
} 

float roundTo2Places(float v) {
  return floor(v*10 + 0.5) / 10.0;
}

void processOSCFireEvent(OscMessage m) {

 debug("FC OSC: " + m.addrPattern());
  
  if (m.addrPattern().startsWith("/fireMasterArm/makeFire")) {
    fcUIMasterFireArm = m.get(0).floatValue() != 0;
  } 
  
  else if (m.addrPattern().startsWith("/fireControl/mainButton")) {
    if (fcUIMasterFireArm)
       events.fire("mainEffect");
  } 
  
  else if (m.addrPattern().startsWith("/fireControl/mainDuration")) {
    fcUIMainDuration = m.get(0).floatValue();
    sendTouchOSCMsg("/fireControl/pooferDurationLabel", "duration " + roundTo2Places(fcUIMainDuration) + " seconds");  
  } 
 
  else if (m.addrPattern().startsWith("/fireControl/tornadoFan")) {
    // when the fan turns on, note the time
    boolean newFanOn = m.get(0).floatValue() != 0;
    
    if (newFanOn && !fcUITornadoFan) {
      fcFanOnTime = now();                                   // fan going on, note time
//     debug("turning on fan");
    } else if (!newFanOn && fcUITornadoReady) {
      fcUITornadoReady = false;
      fcUITornadoFuel = false;      
      sendTouchOSCMsg("/fireControl/tornadoReady", false);   // fan went off, turn off ready light and poofer
      sendTouchOSCMsg("/fireControl/tornadoFuel", false);
    }
    
    fcUITornadoFan = newFanOn;
  } 

  else if (m.addrPattern().startsWith("/fireControl/tornadoFuel")) {
   boolean newFuelOn = m.get(0).floatValue() != 0;
   
   // don't let the fuel come on without the ready light
   if (newFuelOn) {
     if (!fcUITornadoReady || !fcUIMasterFireArm) {
       newFuelOn = false;
       sendTouchOSCMsg("/fireControl/tornadoFuel", false);
 //      debug("fan not ready");
     }
   }
   fcUITornadoFuel = newFuelOn;
  } 
}

// Sets a fire control relay to specified state. 
void fireDMX(int addr, boolean onOff) {
  if (onOff) {
  	boolean denyFire = false;
    
    // Only check the blacklist when igniting and in 7/8 disable, not when turning off.
    if (FLAME_EFFECTS_78_DISABLE) {
      fireBlacklistInteger = addr;
      denyFire = fireBlacklist.contains(fireBlacklistInteger);
    }
    
    // Check for ignition denial
    if (!denyFire) {
      sendDMX(addr, FIRE_DMX_MAGIC);
    }
  } else {
    sendDMX(addr, 0);
  }
}

// XXX this is EXACTLY identical to fireDMX(), and we should probably get rid of it
// for more details, see http://lists.syzygryd.com/private.cgi/code-syzygryd.com/2011-March/001563.html
void fireDMXRaw(int addr, boolean onOff) {
  if (onOff) {
  	boolean denyFire = false;
    
    // Only check the blacklist when igniting and in 7/8 disable, not when turning off.
    if (FLAME_EFFECTS_78_DISABLE) {
      fireBlacklistInteger = addr;
      denyFire = fireBlacklist.contains(fireBlacklistInteger);
    }
    
    // Check for ignition denial
    if (!denyFire) {
      sendDMX(addr, FIRE_DMX_MAGIC);
    }
  } else {
    sendDMX(addr, 0);
  }
}

// Advance times the main effect shot and the fan ready light, and sends DMX
void fireControlAdvance(float steps) {

  int curTime = now();
 
  // fire the main effect if we got an OSC message
  if (events.fired("mainEffect")) {
    fcMainOnTime = curTime;
    fcMainOn = true;
    debug("fired");
  }
 
  // Turn the main effect off if it's been on long enough
  if (fcMainOn && ((curTime - fcMainOnTime) > fcUIMainDuration*1000)) {
    fcMainOn = false;
  }
 
  // Turn on the ready light if the fan's been on for the warmup time
  if (fcUITornadoFan && !fcUITornadoReady && ((curTime - fcFanOnTime) > FAN_WARMUP_TIME)) {
    fcUITornadoReady = true;
    sendTouchOSCMsg("/fireControl/tornadoReady", true);
  }
 
  // Send DMX to control relays
  fireDMX(POOFER_DMX_ADDR, fcMainOn);
  fireDMX(TORNADO_FAN_DMX_ADDR, fcUITornadoFan);
  fireDMX(TORNADO_FUEL_DMX_ADDR, fcUITornadoFuel);
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
